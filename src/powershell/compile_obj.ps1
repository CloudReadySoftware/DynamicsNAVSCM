Param(
  [Parameter(Mandatory)]
  [String[]]$Modules,
  [Parameter(Mandatory)] 
  [String]$NAVIDE, # Must be called NAVIDE for modules sake
  [Parameter(Mandatory)]
  [String]$DatabaseName,
  [Parameter()]
  [Switch]$Foreground
)

foreach($module in $Modules)
{
  Import-Module $module -DisableNameChecking
  Set-Location $env:SystemDrive
}

if(!(Test-Path $NAVIDE)) {
  throw "Cannot find NAV at '$NAVIDE'"
}
$Background = -not $Foreground
$Background = $false
if($Background)
{
  Write-Host "Compiling in the background"
}

Start-IDECompileNAVObject -Modules $Modules -NAVIDE $NAVIDE -DatabaseName $DatabaseName -Background:$Background