Param(
  [Parameter()]
  [ValidateScript({Test-Path -Path $PSItem -PathType Container})]
  [String]$Repo
)

Import-Module (Join-Path $PSScriptRoot "module.psm1")

Set-GitNAVSettings -LocalRepo $Repo

Test-NAVFile $NAVRTC

$ArgumentsList = "DynamicsNAV://{0}/{1}//" -f $env:computername, $NAVServiceInstance
Start-Process $NAVRTC -ArgumentList $ArgumentsList