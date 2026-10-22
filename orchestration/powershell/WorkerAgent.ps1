# MÖBIUS-14 PowerShell Worker Agent
# Cooperative cycle-stealing, resource-quota aware, lease-based

param(
    [string]$LeaseId,
    [int]$MaxCpuPercent = 40,
    [int]$MaxMemoryMB = 2048,
    [string]$WorkPayload
)

$ErrorActionPreference = "Stop"

function Get-CpuUsage {
    (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
}

function Get-MemoryPressure {
    $os = Get-CimInstance Win32_OperatingSystem
    [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1KB, 0)
}

$cpu = Get-CpuUsage
$mem = Get-MemoryPressure

if ($cpu -gt $MaxCpuPercent -or $mem -gt $MaxMemoryMB) {
    Write-Output @{ Status = "deferred"; Reason = "resource_quota" } | ConvertTo-Json
    exit 0
}

$workHash = (Get-FileHash -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($WorkPayload))) -Algorithm SHA256).Hash

Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 300)

$result = @{
    Status      = "completed"
    LeaseId     = $LeaseId
    WorkHash    = $workHash
    Timestamp   = (Get-Date).ToUniversalTime().ToString("o")
    CpuObserved = $cpu
    MemObserved = $mem
}

$result | ConvertTo-Json -Depth 4
