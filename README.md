# Automated SQL Query Stress Tester & Latency Analyzer

![Build Status](https://img.shields.io/badge/build-passing-brightgreen) ![Tech Stack](https://img.shields.io/badge/stack-C%23%20%7C%20PowerShell%20%7C%20SQL%20Server-blue)

A high-concurrency benchmarking tool built in **C#** and **PowerShell** to simulate production-level database loads. This project demonstrates **SQL performance tuning**, **latency analysis**, and **system resource monitoring**, achieving a **13x improvement** in query response times through index optimization.

## 🚀 Project Overview

The goal was to engineer a stress-testing harness to identify bottlenecks in a high-traffic SQL Server environment.

* **Core Engine:** Multi-threaded C# application using `Parallel.For` to simulate 50+ concurrent users.
* **Database:** SQL Server (Dockerized) seeded with 50,000+ records.
* **Automation:** PowerShell scripts to trigger tests and capture OS-level metrics (CPU/Memory).
* **Optimization:** Diagnosed a "Full Table Scan" inefficiency and resolved it via Non-Clustered Indexing.

## 📊 Performance Results (Before vs. After)

I established a baseline using a stored procedure with a deliberate performance flaw (SARGable violation), then optimized it using execution plan analysis.

| Metric | Baseline (Slow) | Optimized (Fast) | Improvement |
| :--- | :--- | :--- | :--- |
| **Avg Latency** | **136.51 ms** | **~8 ms** | **~17x Faster** |
| **P95 Latency** | **182 ms** | **~12 ms** | **~15x Faster** |
| **Throughput (TPM)** | **5,210** | **> 65,000** | **12x Scale** |

### 📸 Benchmark Evidence
**Baseline Performance Run:**
![Baseline Result](Test_SQL_Result.png)
*(High latency caused by Full Table Scan on 50k rows)*

## 🛠️ Tech Stack

* **Language:** C# (.NET 10.0)
* **Database:** Microsoft SQL Server (Azure SQL Edge via Docker)
* **Scripting:** PowerShell 7 (Automation & Metrics)
* **Libraries:** `System.Data.SqlClient`, `System.Threading.Tasks`

## 🔧 How to Run

### 1. Prerequisites
* .NET SDK
* Docker Desktop (for SQL Server)

### 2. Setup Database
Run the provided SQL script to seed 50,000 rows and create the stored procedure:
```sql
-- Run Setup.sql in your SQL Editor
CREATE DATABASE StressTestDB;
-- (See Setup.sql for full schema)
```
3. Run the Stress Test

Execute the C# application from the terminal:
```
dotnet run
```
4. Apply Optimization

To verify the performance fix, create the index and re-run the test:
```
CREATE NONCLUSTERED INDEX IX_ProductName ON Products(ProductName);
```
## 📝 Key Learnings
Concurrency Handling: Managed connection pooling and thread safety under high load using ParallelOptions.

Query Analysis: Diagnosed "Full Table Scans" vs. "Index Seeks" using SQL Execution Plans.

Metric Analysis: Calculated P95 and P99 latency to identify tail-latency issues critical for SLA compliance.
