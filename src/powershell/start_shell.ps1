#Requires -RunAsAdministrator

param(
  [Parameter(Mandatory)]
  [String[]]$Variables,
  [Parameter(Mandatory)]
  [String[]]$Modules
  )

$shellfile = Join-Path $PSScriptRoot "shell.ps1"
$modulesParameter = '-Modules "{0}"' -f ($Modules -join ';')
$VariablesParameter = '-Variables "{0}"' -f ($Variables -join ';')
$FileParameter = '-File "{0}"' -f $shellfile
Start-Process powershell -ArgumentList "-NoProfile","-NoExit","-ExecutionPolicy ByPass",$FileParameter,$modulesParameter,$VariablesParameter -Verb RunAs