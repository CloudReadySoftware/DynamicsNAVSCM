#Requires -RunAsAdministrator

param(
  [Parameter(Mandatory)]
  [String[]]$Variables,
  [Parameter(Mandatory)]
  [String[]]$Modules
  )

$NewVariables = $Variables -split ";"
$NewModules = $Modules -split ";"
$repository = $false
$SolutionName = ""

foreach($Module in $NewModules)
{
  Import-Module $Module -ErrorAction Stop -DisableNameChecking
  Set-Location $env:SystemDrive
}

if($NewVariables.Count -lt 2) 
{
  throw "Not enough variables"
}

if($NewVariables.Count % 2 -ne 0)
{
  throw "Uneven variable length"
}

$VariablesTable = @{}

for($i = 0; $i -lt $NewVariables.Count;$i += 2)
{
  $Name = $NewVariables[$i]
  $Value = $NewVariables[$i + 1]
  $VariablesTable.Add($Name, $Value)
  Set-Variable -Name $Name -Value $Value
}
if($repository) {
  if(Test-Path $repository)
  {
    Push-Location $repository
  }
}
if($SolutionName) {
  Write-Host "Shell for '$SolutionName'"
}
Write-Host 'Content of $VariablesTable:'
$VariablesTable
