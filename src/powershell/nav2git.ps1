Param(
  [Parameter(Mandatory)]
  [String[]]$Modules,
  [Parameter(Mandatory)]
  [String]$DatabaseName,
  [Parameter(Mandatory)]
  [String]$NAVIDE,
  [Parameter(Mandatory)]
  [String]$DestinationFolder,
  [Parameter()]
  [String]$TempFolder,
  [Parameter()]
  [String[]]$Filters,
  [Parameter()]
  [Boolean]$DateModification
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

Export-IDENAVObject -DatabaseName $DatabaseName -DestinationFolder $DestinationFolder -TempFolder $TempFolder -Filters $Filters -DateModification $DateModification