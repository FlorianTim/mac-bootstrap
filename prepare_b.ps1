# prepare.ps1
# Robust generator runner: reads Base64 payload, decodes to PS script, executes it.
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File .\prepare.ps1 -B64Path .\payload.b64 -OutDir .
# Optional:
#   -Encoding Unicode | UTF8
#   -WriteDecodedOnly (do not execute)

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$B64Path,

    [Parameter(Mandatory = $false)]
    [string]$OutDir = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Unicode', 'UTF8')]
    [string]$Encoding = 'Unicode',

    [Parameter(Mandatory = $false)]
    [switch]$WriteDecodedOnly
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $B64Path)) {
    throw "Base64 file not found: $B64Path"
}

# Read Base64 as a single string (strip whitespace/newlines)
$b64Raw = Get-Content -LiteralPath $B64Path -Raw
$b64 = ($b64Raw -replace '\s+', '')

# Decode
$bytes = [Convert]::FromBase64String($b64)

$decoded =
if ($Encoding -eq 'UTF8') { [Text.Encoding]::UTF8.GetString($bytes) }
else { [Text.Encoding]::Unicode.GetString($bytes) }  # UTF-16LE

# Write decoded script for auditing
$decodedPath = Join-Path $OutDir 'decoded-generator.ps1'
Set-Content -LiteralPath $decodedPath -Value $decoded -Encoding UTF8

Write-Host "Decoded generator written to: $decodedPath"

if ($WriteDecodedOnly) {
    Write-Host "WriteDecodedOnly set -> not executing decoded script."
    exit 0
}

# Execute decoded script in OutDir
Push-Location $OutDir
try {
    # Execute as a script block
    $sb = [ScriptBlock]::Create($decoded)
    & $sb
}
finally {
    Pop-Location
}
