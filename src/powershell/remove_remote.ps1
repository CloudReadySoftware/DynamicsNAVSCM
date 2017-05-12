Param(
  [Parameter()]
  [ValidateScript({Test-Path -Path $PSItem -PathType Container})]
  [String]$Repo
)

Import-Module (Join-Path $PSScriptRoot "module.psm1")

Set-GitNAVRemoteSettings -LocalRepo $Repo

if(Test-Path $global -PathType Container)
{  
  Get-ChildItem -Path $global -Recurse -Force | Remove-Item -Force -Recurse
  Remove-Item $BaseFolder -Force -Recurse
}