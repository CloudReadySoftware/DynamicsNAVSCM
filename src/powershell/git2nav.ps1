Param(
  [Parameter(Mandatory)]
  [String[]]$Modules,
  [Parameter(Mandatory)]
  [String]$ObjectsFolder,
  [Parameter(Mandatory)]
  [String]$WorkspaceFolder,
  [Parameter(Mandatory)]
  [String]$SolutionName,
  [Parameter(Mandatory)]
  [String]$DatabaseName,
  [Parameter(Mandatory)]
  [String]$LastImportGitHashFilepath
)

foreach($Module in $Modules)
{
  Import-Module $Module -ErrorAction Stop -DisableNameChecking
  Set-Location $env:SystemDrive
}
if(-not (Test-Path $NAVIDE))
{
  throw "Cant find NAVIDE at $NAVIDE"
}

Import-IDENAVObject -ObjectsFolder $ObjectsFolder -Workspacefolder $WorkspaceFolder -SolutionName $SolutionName -DatabaseName $DatabaseName -LastImportGitHashFilepath $LastImportGitHashFilepath