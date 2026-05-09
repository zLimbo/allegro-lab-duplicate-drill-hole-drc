param(
    [Parameter(Mandatory = $true)]
    [string]$BoardPath,

    [string]$OutputBoardPath = "",

    [string]$ReportPath = "",

    [string]$CadenceBin = "C:\Cadence\SPB_24.1\tools\bin",

    [switch]$ReportOnly
)

$ErrorActionPreference = "Stop"

function Resolve-RequiredFile {
    param([string]$PathValue, [string]$Label)
    $resolved = Resolve-Path -LiteralPath $PathValue -ErrorAction Stop
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Label is not a file: $PathValue"
    }
    return $resolved.Path
}

function Get-RequiredTool {
    param([string]$ToolName)
    $tool = Join-Path $CadenceBin $ToolName
    if (-not (Test-Path -LiteralPath $tool -PathType Leaf)) {
        throw "Tool not found: $tool"
    }
    return $tool
}

$board = Resolve-RequiredFile $BoardPath "BoardPath"
$dbdoctor = Get-RequiredTool "dbdoctor.exe"
$report = Get-RequiredTool "report.exe"

if ([string]::IsNullOrWhiteSpace($OutputBoardPath)) {
    $boardDir = Split-Path -Parent $board
    $boardBase = [System.IO.Path]::GetFileNameWithoutExtension($board)
    $OutputBoardPath = Join-Path $boardDir "$boardBase.drc_only.brd"
}

if ([string]::IsNullOrWhiteSpace($ReportPath)) {
    $reportDir = Join-Path (Get-Location).Path "reports"
    New-Item -ItemType Directory -Force -Path $reportDir | Out-Null
    $reportBase = [System.IO.Path]::GetFileNameWithoutExtension($OutputBoardPath)
    $ReportPath = Join-Path $reportDir "$reportBase.drc.rpt"
}

if (-not $ReportOnly) {
    Write-Host "Running DRC into board copy:"
    Write-Host "  Input : $board"
    Write-Host "  Output: $OutputBoardPath"
    & $dbdoctor -drc_only -outfile $OutputBoardPath $board
    if ($LASTEXITCODE -ne 0) {
        throw "dbdoctor failed with exit code $LASTEXITCODE"
    }
    $boardForReport = $OutputBoardPath
} else {
    Write-Host "ReportOnly set; skipping dbdoctor -drc_only."
    $boardForReport = $board
}

Write-Host "Exporting DRC report:"
Write-Host "  Board : $boardForReport"
Write-Host "  Report: $ReportPath"
& $report -v drc $boardForReport $ReportPath
if ($LASTEXITCODE -ne 0) {
    throw "report failed with exit code $LASTEXITCODE"
}

Write-Host "Done."
