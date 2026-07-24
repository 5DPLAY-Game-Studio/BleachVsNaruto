# =============================================================================
# wait_swc_ready.ps1
#
# Wait until a SWC exists, size is stable, and the file can be opened for write
# (IDEA Flex compiler often locks it briefly after Make).
# ASCII-only. Shared by asdoc_shared / LIB_KyoLib embed hooks.
# =============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string] $SwcPath,

    [int] $TimeoutSec = 45,
    [int] $StableMs = 400
)

$ErrorActionPreference = 'Stop'

$deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSec)
$lastSize = -1
$stableSince = [DateTime]::MinValue

while ([DateTime]::UtcNow -lt $deadline) {
    if (-not (Test-Path -LiteralPath $SwcPath)) {
        Start-Sleep -Milliseconds 200
        continue
    }

    $size = (Get-Item -LiteralPath $SwcPath).Length
    if ($size -ne $lastSize) {
        $lastSize = $size
        $stableSince = [DateTime]::UtcNow
        Start-Sleep -Milliseconds 100
        continue
    }

    if (([DateTime]::UtcNow - $stableSince).TotalMilliseconds -lt $StableMs) {
        Start-Sleep -Milliseconds 100
        continue
    }

    try {
        $fs = [System.IO.File]::Open(
            $SwcPath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::ReadWrite,
            [System.IO.FileShare]::None
        )
        $fs.Close()
        Write-Host ("swc_ready={0}" -f $SwcPath)
        exit 0
    }
    catch {
        Start-Sleep -Milliseconds 200
    }
}

Write-Host ("swc_not_ready={0}" -f $SwcPath)
exit 1
