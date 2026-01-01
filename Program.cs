using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;

class Program
{
    // CONFIGURATION (Mac/Docker Compatible)
    static string connectionString = "Server=localhost;Database=StressTestDB;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True;";
    static int totalRequests = 1000; // How many queries to run
    static int maxConcurrency = 50;  // How many threads at once

    static void Main(string[] args)
    {
        Console.WriteLine($"Starting Stress Test: {totalRequests} requests with {maxConcurrency} threads...");
        
        var latencies = new ConcurrentBag<long>();
        var sw = Stopwatch.StartNew();

        Parallel.For(0, totalRequests, new ParallelOptions { MaxDegreeOfParallelism = maxConcurrency }, i =>
        {
            var latency = ExecuteQuery();
            latencies.Add(latency);
        });

        sw.Stop();
        
        // METRICS CALCULATION
        if (latencies.Count == 0) 
        {
            Console.WriteLine("No queries succeeded. Check connection.");
            return;
        }

        var sorted = latencies.OrderBy(x => x).ToList();
        Console.WriteLine("\n--- PERFORMANCE RESULTS ---");
        Console.WriteLine($"Total Time:      {sw.ElapsedMilliseconds} ms");
        Console.WriteLine($"Avg Latency:     {sorted.Average():F2} ms");
        Console.WriteLine($"Min Latency:     {sorted.First()} ms");
        Console.WriteLine($"Max Latency:     {sorted.Last()} ms");
        Console.WriteLine($"P95 Latency:     {sorted[(int)(sorted.Count * 0.95)]} ms");
        Console.WriteLine($"TPM (Est):       {(totalRequests / sw.Elapsed.TotalMinutes):F0} trans/min");
    }

    static long ExecuteQuery()
    {
        Stopwatch querySw = new Stopwatch();
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            using (SqlCommand cmd = new SqlCommand("GetProductsSlow", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@SearchTerm", "500"); // Searching for '500' in name

                try
                {
                    querySw.Start();
                    conn.Open();
                    var result = cmd.ExecuteScalar(); 
                    querySw.Stop();
                }
                catch (Exception ex)
                {
                    // Uncomment below to see specific errors
                    // Console.WriteLine($"Error: {ex.Message}");
                    return 0;
                }
            }
        }
        return querySw.ElapsedMilliseconds;
    }
}