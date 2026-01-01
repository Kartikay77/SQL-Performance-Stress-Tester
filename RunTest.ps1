# SQL Performance Test Automation Script
$ExePath = ".\SqlStressTester\bin\Debug\net6.0\SqlStressTester.exe"
$LogFile = ".\perf_metrics.csv"

Write-Host "--- STARTING SQL STRESS TEST SUITE ---" -ForegroundColor Cyan

# 1. Check if Executable exists
if (-not (Test-Path $ExePath)) {
    Write-Error "Executable not found! Run 'dotnet build' first."
    exit
}

# 2. Start Performance Monitoring (Background Job)
# Captures SQL Server CPU usage every 1 second
$PerfJob = Start-Job -ScriptBlock {
    $path = $args[0]
    # Note: Use "\Processor(_Total)\% Processor Time" if SQL specific counter fails
    Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 100 | 
    Export-Counter -Path $path -Force
} -ArgumentList $LogFile

Write-Host "Monitoring OS Metrics (CPU/RAM)..." -ForegroundColor Yellow

# 3. Run the C# Application
Write-Host "Launching C# Stress Tester..." -ForegroundColor Green
$TestTime = Measure-Command {
    # Calls the compiled C# app
    & $ExePath
}

# 4. Cleanup
Stop-Job $PerfJob
Remove-Job $PerfJob

Write-Host "`nTest Completed in $($TestTime.TotalSeconds) seconds." -ForegroundColor Cyan
Write-Host "OS Metrics saved to $LogFile" -ForegroundColor Cyan