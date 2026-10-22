param(
    [Parameter(Mandatory=$true)][string]$LeaseId,
    [Parameter(Mandatory=$true)][string]$Payload,
    [int]$MaxCpu = 40,
    [int]$MaxMemMB = 2048
)

& "$PSScriptRoot\WorkerAgent.ps1" -LeaseId $LeaseId -MaxCpuPercent $MaxCpu -MaxMemoryMB $MaxMemMB -WorkPayload $Payload
