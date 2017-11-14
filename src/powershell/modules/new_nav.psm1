
function Import-NAVLicense 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$NAVLicenseFile,
    [Parameter(Mandatory)]
    [String]$ServiceInstanceName
    )
  Process
  {
    if(Test-Path $NAVLicenseFile -PathType Leaf)
    {
      $licensefile = Get-Content -Path $NAVLicenseFile -Encoding Byte
      Import-NAVServerLicense $ServiceInstanceName -LicenseData $licensefile -Database NavDatabase -WarningAction SilentlyContinue
    }
  }
}


function Set-UIDOffset 
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [Int]$uidOffset,
    [Parameter(Mandatory)]
    [String]$DatabaseName
    )
  Process
  {
    if($uidOffset -eq 0)
    {
      return
    }
    $SQLString = 'UPDATE [$ndo$dbproperty] SET [uidoffset] = {0}' -f $uidOffset
    Invoke-Sqlcmd -Query $SQLString -Database $DatabaseName
  }
}

function Expand-NAVArchive 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ZipFile,
    [Parameter(Mandatory)]
    [String]$NSTFolder,
    [Parameter(Mandatory)]
    [String]$RTCFolder,
    [Parameter(Mandatory)]
    [bool]$ServiceTier,
    [Parameter(Mandatory)]
    [bool]$RoleTailoredClient
    )
  Process
  {
    $tempfolder = Get-TempFolder
    $ZipFileName = Copy-Item -Path $ZipFile -Destination $tempfolder -PassThru
    $ExtractedNAVFiles = Join-Path $tempfolder "NAV"
    $null = New-Item -ItemType Directory $ExtractedNAVFiles
    Expand-Archive $ZipFileName $ExtractedNAVFiles -Verbose:$false
    $NAVVersionFolder = Join-Path $ExtractedNAVFiles 'RoleTailoredClient\program files\Microsoft Dynamics NAV\'
    $NAVVersion = Get-ChildItem -Directory -Path $NAVVersionFolder | Select-Object -First 1 -ExpandProperty "Name"
    if ($ServiceTier) {
      Copy-ServiceTier -ExtractedNAVFiles $ExtractedNAVFiles -NSTFolder $NSTFolder -NAVVersion $NAVVersion
    }
    if ($RoleTailoredClient) {
      Copy-RoleTailoredClient -ExtractedNAVFiles $ExtractedNAVFiles -RTCFolder $RTCFolder -NAVVersion $NAVVersion
    }
    Remove-Item $tempfolder -Recurse -Force -ErrorAction 'SilentlyContinue'
  }
}

function Copy-ServiceTier
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ExtractedNAVFiles,
    [Parameter(Mandatory)]
    [String]$NSTFolder,
    [Parameter(Mandatory)]
    [String]$NAVVersion
  )
  Process
  {
    
    if(-not (Test-Path $NSTFolder))
    {
      $null = New-Item -Path $NSTFolder -ItemType Directory
    }
    $BaseFiles = Join-Path $ExtractedNAVFiles "ServiceTier\program files\Microsoft Dynamics NAV\$NAVVersion\Service\*"
    $LanguageFiles = Join-Path $ExtractedNAVFiles "Installers\*\Server\PFiles\Microsoft Dynamics NAV\$NAVVersion\Service\*"
    Copy-Item -Path $BaseFiles -Destination $NSTFolder -Recurse
    Copy-Item -Path $LanguageFiles -Destination $NSTFolder -Recurse -Force
  }
}

function Copy-RoleTailoredClient
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ExtractedNAVFiles,
    [Parameter(Mandatory)]
    [String]$RTCFolder,
    [Parameter(Mandatory)]
    [String]$NAVVersion
  )
  Process
  {
    if(-not (Test-Path $RTCFolder))
    {
      $null = New-Item -Path $RTCFolder -ItemType Directory
    }
    $BaseFiles = Join-Path $ExtractedNAVFiles "RoleTailoredClient\program files\Microsoft Dynamics NAV\$NAVVersion\RoleTailored Client\*"
    $LanguageFiles = Join-Path $ExtractedNAVFiles "Installers\*\RTC\PFiles\Microsoft Dynamics NAV\$NAVVersion\RoleTailored Client\*"
    Copy-Item -Path $BaseFiles -Destination $RTCFolder -Recurse
    Copy-Item -Path $LanguageFiles -Destination $RTCFolder -Recurse -Force
    Copy-UserSettings -ExtractedNAVFiles $ExtractedNAVFiles -NAVVersion $NAVVersion
  }
}

function Copy-UserSettings
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ExtractedNAVFiles,
    [Parameter(Mandatory)]
    [String]$NAVVersion
  )
  Process
  {
    $UserSettings = Join-Path $env:appdata "Microsoft\Microsoft Dynamics NAV\$NAVVersion\ClientUserSettings.config"
    if (Test-Path $UserSettings)
    {
      return
    }
    $UserSettingsFolder = Split-Path $UserSettings
    if(-not (Test-Path $UserSettingsFolder))
    {
      $null = New-Item -ItemType Directory $UserSettingsFolder
    }  
    $DefaultUserSettings = Join-Path $ExtractedNAVFiles "RoleTailoredClient\CommonAppData\Microsoft\Microsoft Dynamics NAV\$NAVVersion\ClientUserSettings.config"
    Copy-Item -Path $DefaultUserSettings -Destination $UserSettings 
  }
}


function Assert-AdminProcess
{
  [CmdletBinding()]
  Param(
    )
  Process
  {
    $currentUser = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdminProcess = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if(-not $isAdminProcess)
    {
      throw "The process cannot be completed because it isnt running as admin."
    }
  }
}

function Copy-NAVConfig { 
  [CmdletBinding()] 
  Param( 
    [Parameter(Mandatory)] 
    [String]$ServiceFolder, 
    [Parameter(Mandatory)] 
    [String]$DatabaseName, 
    [Parameter(Mandatory)] 
    [String]$ServiceInstanceName, 
    [Parameter(Mandatory)] 
    [String]$ConfigLocation 
    ) 
  Process
  {
    $ConfigFolder = Join-Path $ConfigLocation $ServiceInstanceName 
    $null = New-Item -Type Directory $ConfigFolder
    $XmlFile = Join-Path $ServiceFolder "CustomSettings.config" 
    [xml]$configXML = Get-Content $XmlFile 
    $configXML.appSettings.add | Where-Object {$_.key -eq "DatabaseName"} | ForEach-Object {$_.value = $DatabaseName} 
    $configXML.appSettings.add | Where-Object {$_.key -eq "ServerInstance"} | ForEach-Object {$_.value = $ServiceInstanceName} 
    $configFileName = Join-Path $ConfigFolder "CustomSettings.config" 
    $configXML.Save($configFileName) 
    $tenantsConfig = Join-Path $ServiceFolder "Tenants.config" 
    if(Test-Path $tenantsConfig){
      Copy-Item $tenantsConfig $ConfigFolder 
    }
    $configFile = Join-Path $ServiceFolder "Microsoft.Dynamics.Nav.Server.exe.config" 
    $configFileName = Join-Path $ConfigFolder "$ServiceInstanceName.config" 
    Copy-Item $ConfigFile $configFilename -PassThru 
  } 
}

function Test-NAVInstanceWindows10 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$NAVServiceInstance
    )
  Process
  {
    if ([Environment]::OSVersion.Version.Major -ne 10)
    {
      return
    }
    $module = Get-Module -Name "Microsoft.Dynamics.Nav.Management"
    if(!$module)
    {
      return
    }
    $moduleItem = Get-Item $module.Path
    $versionInfo = $moduleItem.VersionInfo
    if(($versionInfo.ProductMajorPart -le 8) -and ($versionInfo.ProductBuildPart -le 41779))
    {
      Invoke-NAVCodeunit -CodeunitId 1 -ServerInstance $NAVServiceInstance -ErrorAction SilentlyContinue
    }
  }
}


function Install-NAVAddIns 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$SourceAddinsFolder,
    [Parameter(Mandatory)]
    [String]$RTCAddinsFolder, 
    [Parameter(Mandatory)]
    [String]$NSTAddinsFolder    
    )
  Process
  {
    if(-not (Test-Path $SourceAddinsFolder)) {
      return
    }
    $AddIns = Get-ChildItem $SourceAddinsFolder
    if(-not $AddIns)
    {
      return
    }
    $AddInFiles = $AddIns.FullName
    if($NSTAddinsFolder)
    {
      $null = New-Item -ItemType Directory -Force -Path $NSTAddinsFolder
      Copy-Item $AddInFiles $NSTAddinsFolder -Force
    }
    $null = New-Item -ItemType Directory -Force -Path $RTCAddinsFolder
    Copy-Item $AddInFiles $RTCAddinsFolder -Force
  }
}

function New-NAVServiceTier
{ 
  [CmdletBinding()] 
  Param( 
    [Parameter(Mandatory)]
    [String]$NSTFolder,
    [Parameter(Mandatory)]
    [String]$DatabaseName,
    [Parameter(Mandatory)]
    [String]$ServiceInstanceName,
    [Parameter(Mandatory)]
    [String]$NSTEXE
    ) 
  Process
  { 
    $ConfigLocation = Join-Path $NSTFolder "Instances"
    $ConfigFile = Copy-NAVConfig -ServiceFolder $NSTFolder -DatabaseName $DatabaseName -ServiceInstanceName $ServiceInstanceName -ConfigLocation $ConfigLocation
    $binPath = "`"{1}`" `${0} config `"{2}`"" -f $ServiceInstanceName, $NSTEXE, $ConfigFile
    $Dependencies = "HTTP","NetTcpPortSharing"
    $DisplayName = "Microsoft Dynamics NAV Server [{0}]" -f $ServiceInstanceName
    $Description = "Service handling requests to Microsoft Dynamics NAV application."
    $ServiceName = 'MicrosoftDynamicsNavServer${0}' -f $ServiceInstanceName
    $null = New-Service -Name $ServiceName -BinaryPathName $binPath -DisplayName $DisplayName -Description $Description -StartupType Automatic -DependsOn $Dependencies
  } 
}

function Set-ServiceCredential
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String]$ServiceInstanceName
  )
  $ServiceCredential = Get-Credential -Message "Credentials for '$ServiceInstanceName'" -UserName $(whoami)
  $filter =  'Name = "MicrosoftDynamicsNavServer${0}"' -f $ServiceInstanceName
  $services = Get-WmiObject -Class "Win32_Service" -Filter $filter
  if($services) 
  {
    $MultipleServices = [bool](Get-Member -InputObject $services -Name 'Count' -MemberType Properties)
  }
  if ((-not $services) -or ($MultipleServices)) {
    throw "Unable to find services named '$ServiceInstanceName'."
  }
  Set-ServiceCredentials -Service $services -ServiceCredential $ServiceCredential
}

function Set-ServiceCredentials
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [System.Management.ManagementObject[]] $Service,
    [Parameter(Mandatory)]
    [Management.Automation.PSCredential] $ServiceCredential
  )
  process { 
    $changeService = $Service.Change($null,                    # DisplayName
          $null,                                               # PathName
          $null,                                               # ServiceType
          $null,                                               # ErrorControl
          $null,                                               # StartMode
          $null,                                               # DesktopInteract
          $serviceCredential.UserName,                         # StartName
          $serviceCredential.GetNetworkCredential().Password,  # StartPassword
          $null,                                               # LoadOrderGroup
          $null,                                               # LoadOrderGroupDependencies
          $null)                                               # ServiceDependencies
    $returnValue = $changeService.ReturnValue                                  
    $errorMessage = "Error setting credentials for service '$serviceName'"
    switch ( $returnValue ) {
      0  { Write-Verbose "Set credentials for service '$serviceName'" }
      1  { Write-Error "$errorMessage - Not Supported" }
      2  { Write-Error "$errorMessage - Access Denied" }
      3  { Write-Error "$errorMessage - Dependent Services Running" }
      4  { Write-Error "$errorMessage - Invalid Service Control" }
      5  { Write-Error "$errorMessage - Service Cannot Accept Control" }
      6  { Write-Error "$errorMessage - Service Not Active" }
      7  { Write-Error "$errorMessage - Service Request timeout" }
      8  { Write-Error "$errorMessage - Unknown Failure" }
      9  { Write-Error "$errorMessage - Path Not Found" }
      10 { Write-Error "$errorMessage - Service Already Stopped" }
      11 { Write-Error "$errorMessage - Service Database Locked" }
      12 { Write-Error "$errorMessage - Service Dependency Deleted" }
      13 { Write-Error "$errorMessage - Service Dependency Failure" }
      14 { Write-Error "$errorMessage - Service Disabled" }
      15 { Write-Error "$errorMessage - Service Logon Failed" }
      16 { Write-Error "$errorMessage - Service Marked For Deletion" }
      17 { Write-Error "$errorMessage - Service No Thread" }
      18 { Write-Error "$errorMessage - Status Circular Dependency" }
      19 { Write-Error "$errorMessage - Status Duplicate Name" }
      20 { Write-Error "$errorMessage - Status Invalid Name" }
      21 { Write-Error "$errorMessage - Status Invalid Parameter" }
      22 { Write-Error "$errorMessage - Status Invalid Service Account" }
      23 { Write-Error "$errorMessage - Status Service Exists" }
      24 { Write-Error "$errorMessage - Service Already Paused" }
    }
  }
}