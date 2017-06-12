#Requires -RunAsAdministrator

Param(
  [Parameter(Mandatory)]
  [String[]]$Modules,
  [Parameter(Mandatory)]
  [String]$Zip,
  [Parameter(Mandatory)]
  [String]$ServiceInstanceName,
  [Parameter(Mandatory)]
  [String]$NSTFolder,
  [Parameter(Mandatory)]
  [String]$RTCFolder,
  [Parameter(Mandatory)]
  [String]$Addinsfolder,
  [Parameter(Mandatory)]
  [String]$RTCAddinsFolder,
  [Parameter(Mandatory)]
  [String]$NSTAddinsFolder,
  [Parameter(Mandatory)]
  [String]$LicenseFile,
  [Parameter(Mandatory)]
  [Int]$UIDOffset,
  [Parameter(Mandatory)]
  [String]$DatabaseName,
  [Parameter(Mandatory)]
  [String]$NSTEXE
)

$UnloadedModules = @()
foreach($Module in $Modules)
{
  if(($Module -match "[/\\]") -and (-not (Test-Path $Module))){
    $UnloadedModules += $Module
  } else {
    Import-Module $Module
    Set-Location $env:SystemDrive
  }
}

Write-Host "TODO: Check if db server and db name exists..."

Assert-AdminProcess

$NSTFolderMissing = -not (Test-Path -Path $NSTFolder -PathType Container)
$RTCFolderMissing = -not (Test-Path -Path $RTCFolder -PathType Container)
if($NSTFolderMissing -or $RTCFolderMissing)
{
  Expand-NAVArchive -ZipFile $Zip -NSTFolder $NSTFolder -RTCFolder $RTCFolder -ServiceTier $NSTFolderMissing -RoleTailoredClient $RTCFolderMissing
}

foreach($UnloadedModule in $UnloadedModules)
{
  Import-Module $UnloadedModule
}

#TODO: Remove generation of $FullServiceName
$FullServiceName = 'MicrosoftDynamicsNavServer${0}' -f $ServiceInstanceName

$Service = Get-Service -Name $FullServiceName -ErrorAction "SilentlyContinue"

if(-not $Service)
{
  New-NAVServiceTier -NSTFolder $NSTFolder -DatabaseName $DatabaseName -ServiceInstanceName $ServiceInstanceName -NSTEXE $NSTEXE
  $Service = Get-Service -Name $FullServiceName
}

if($Service.Status -ne "Running")
{
  Start-Service $FullServiceName
}

Test-NAVInstanceWindows10 -NAVServiceInstance $ServiceInstanceName

Import-NAVLicense -NAVLicenseFile $LicenseFile -ServiceInstanceName $ServiceInstanceName
Stop-Service $FullServiceName
Install-NAVAddIns -SourceAddinsFolder $Addinsfolder -RTCAddinsFolder $RTCAddinsFolder -NSTAddinsFolder $NSTAddinsFolder

Start-Service $FullServiceName
Test-NAVInstanceWindows10 -NAVServiceInstance $ServiceInstanceName


$username = whoami
try 
{
  $isNAVUser = Get-NAVServerUser -ServerInstance $ServiceInstanceName | Where-Object {$PSItem.UserName -eq $username}
  if(-not $isNAVUser)
  {
    $null = New-NAVServerUser -WindowsAccount $username -ServerInstance $ServiceInstanceName
  }

  $isSuperUser = Get-NAVServerUserPermissionSet -PermissionSetId "SUPER" -WindowsAccount $username -ServerInstance $ServiceInstanceName
  if(-not $isSuperUser)
  {
    $null = New-NAVServerUserPermissionSet -PermissionSetId "SUPER" -WindowsAccount $username -ServerInstance $ServiceInstanceName
  }
}
catch
{
  
}

Set-UIDOffset -UIDOffset $UIDOffset -DatabaseName $DatabaseName