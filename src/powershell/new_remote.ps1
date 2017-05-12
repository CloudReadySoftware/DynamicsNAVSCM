Param(
  [Parameter()]
  [ValidateScript({Test-Path -Path $PSItem -PathType Container})]
  [String]$Repo
)

Import-Module (Join-Path $PSScriptRoot "module.psm1")

Set-GitNAVRemoteSettings -LocalRepo $Repo

$RTCFolderMissing = -not (Test-Path -Path $RTCFolder -PathType Container)
if($RTCFolderMissing)
{
  Expand-NAVArchive -RoleTailoredClient $RTCFolderMissing
}

Install-NAVAddIns