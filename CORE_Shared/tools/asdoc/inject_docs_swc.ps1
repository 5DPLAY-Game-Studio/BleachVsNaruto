# =============================================================================
# inject_docs_swc.ps1
#
# Purpose
#   Pack ASDoc intermediate DITA/XML (tempdita) into an existing SWC under
#   docs/, so IDEs (Flash Builder / IDEA / VSCode) can show ASDoc as code hints.
#
# Why
#   compc / IDEA library builds do not embed ASDoc into the SWC. The standard
#   approach is: asdoc -keep-xml=true, then zip tempdita XML/DITA into
#   swc:/docs/ (exclude ASDoc_Config.xml, overviews.xml, and non-XML noise
#   such as XSLT/HTML left when HTML output is also generated).
#
# Usage
#   powershell -NoProfile -ExecutionPolicy Bypass -File inject_docs_swc.ps1 `
#     -SwcPath path\to\CORE_Shared.swc -TempDitaDir path\to\tempdita
#
#   # Exit 0 if SWC already has docs/packages.dita; else exit 1
#   powershell ... -File inject_docs_swc.ps1 -SwcPath path\to\CORE_Shared.swc -TestHasDocs
#
# Notes
#   This file MUST stay ASCII-only (encoding safety), same as build_terms_zh.ps1.
# =============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string] $SwcPath,

    [string] $TempDitaDir = '',

    [switch] $TestHasDocs
)

$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Test-SwcHasPackagesDita([string] $path) {
    if (-not (Test-Path -LiteralPath $path)) {
        return $false
    }
    $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $path).Path)
    try {
        foreach ($entry in $zip.Entries) {
            $name = $entry.FullName -replace '\\', '/'
            if ($name -eq 'docs/packages.dita') {
                return $true
            }
        }
    }
    finally {
        $zip.Dispose()
    }
    return $false
}

if ($TestHasDocs) {
    if (Test-SwcHasPackagesDita $SwcPath) {
        Write-Host 'has_docs=1'
        exit 0
    }
    Write-Host 'has_docs=0'
    exit 1
}

if (-not (Test-Path -LiteralPath $SwcPath)) {
    throw "SWC not found: $SwcPath"
}
if (-not $TempDitaDir -or -not (Test-Path -LiteralPath $TempDitaDir)) {
    throw "tempdita not found: $TempDitaDir"
}

# Adobe / Starling: pack intermediate XML/DITA only; drop config + XSLT/HTML noise
# that appears in tempdita when HTML generation (-skip-xsl=false) is also enabled.
$exclude = @{
    'ASDoc_Config.xml' = $true
    'overviews.xml'    = $true
}

$swcFull  = (Resolve-Path -LiteralPath $SwcPath).Path
$ditaFull = (Resolve-Path -LiteralPath $TempDitaDir).Path
$files    = @(
    Get-ChildItem -LiteralPath $ditaFull -File |
        Where-Object {
            ($_.Extension -eq '.xml' -or $_.Extension -eq '.dita') -and
            (-not $exclude.ContainsKey($_.Name))
        }
)

if ($files.Count -eq 0) {
    throw "No doc XML/DITA files to inject under: $ditaFull"
}

$zip = [System.IO.Compression.ZipFile]::Open(
    $swcFull,
    [System.IO.Compression.ZipArchiveMode]::Update
)
try {
    # Drop previous docs/ entries so re-runs stay clean
    $old = @($zip.Entries | Where-Object {
        ($_.FullName -replace '\\', '/') -like 'docs/*'
    })
    foreach ($entry in $old) {
        $entry.Delete()
    }

    foreach ($file in $files) {
        $entryName = 'docs/' + $file.Name
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip,
            $file.FullName,
            $entryName,
            [System.IO.Compression.CompressionLevel]::Optimal
        )
    }
}
finally {
    $zip.Dispose()
}

Write-Host ("injected={0} swc={1}" -f $files.Count, $swcFull)
