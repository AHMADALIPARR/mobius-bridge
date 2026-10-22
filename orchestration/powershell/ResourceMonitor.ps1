function Get-MobiusResourceSnapshot {
    $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
    $os  = Get-CimInstance Win32_OperatingSystem
    $memUsedMB = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1KB, 0)
    $memTotalMB = [math]::Round($os.TotalVisibleMemorySize / 1KB, 0)

    [PSCustomObject]@{
        CpuPercent   = [math]::Round($cpu, 1)
        MemoryUsedMB = $memUsedMB
        MemoryTotalMB = $memTotalMB
        Timestamp    = (Get-Date).ToUniversalTime().ToString("o")
    }
}

Get-MobiusResourceSnapshot | ConvertTo-Json
