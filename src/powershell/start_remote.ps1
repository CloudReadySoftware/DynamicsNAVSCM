Param(
  [Parameter()]
  [ValidateScript({Test-Path -Path $PSItem -PathType Container})]
  [String]$Repo
)

Import-Module (Join-Path $PSScriptRoot "module.psm1")

Set-GitNAVRemoteSettings -LocalRepo $Repo

Test-NAVFile $NAVIde
$Arguments = "servername={0}, database={1}, ntauthentication=1, id={1}" -f $RemoteDBInstance,$RemoteDBName
Start-Process -FilePath $NAVIde -ArgumentList $Arguments