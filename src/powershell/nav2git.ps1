Param(
  [Parameter(Mandatory)]
  [String[]]$Modules,
  [Parameter(Mandatory)]
  [String]$DatabaseName,
  [Parameter(Mandatory)]
  [String]$NAVIDE,
  [Parameter(Mandatory)]
  [String]$DestinationFolder,
  [Parameter(Mandatory)]
  [String]$SolutionName,
  [Parameter(Mandatory)]
  [String]$NextVersionTag,
  [Parameter(Mandatory)]
  [ValidateSet("all", "solution")]
  [String]$ExportOption
)

foreach($Module in $Modules)
{
  Import-Module $Module -DisableNameChecking
  Set-Location $env:SystemDrive
}
if(-not (Test-Path $NAVIDE))
{
  throw "Cant find NAVIDE at $NAVIDE"
}

Export-IDENAVObject -DatabaseName $DatabaseName -DestinationFolder $DestinationFolder -SolutionName $SolutionName -NextVersionTag $NextVersionTag -ExportOption $ExportOption