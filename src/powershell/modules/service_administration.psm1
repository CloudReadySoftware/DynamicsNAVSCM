#Requires -RunAsAdministrator

function New-NAVServiceTier
{ 
  [CmdletBinding()] 
  Param( 
    ) 
  Process
  { 
    $ConfigLocation = Join-Path $NSTFolder "Instances"
    $ConfigFile = Copy-NAVConfig -ServiceFolder $NSTFolder -DatabaseName $NAVDatabaseName -ServiceInstanceName $NAVServiceInstance -ConfigLocation $ConfigLocation
    $NAVServer = Join-Path $NSTFolder "Microsoft.Dynamics.Nav.Server.exe"
    $binPath = "`"{1}`" `${0} config `"{2}`"" -f $NAVServiceInstance, $NAVServer, $ConfigFile
    $Dependencies = "HTTP","NetTcpPortSharing"
    $DisplayName = "Microsoft Dynamics NAV Server [{0}]" -f $NAVServiceInstance
    $Description = "Service handling requests to Microsoft Dynamics NAV application."
    $null = New-Service -Name $NAVServiceInstanceName -BinaryPathName $binPath -DisplayName $DisplayName -Description  $Description -StartupType Automatic -DependsOn $Dependencies
  } 
}

function Set-ServiceCredential
{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [String]$ServiceInstanceName
  )
  $ServiceCredential = Get-Credential -Message "Credentials for ''$ServiceInstanceName'" -UserName $(whoami)
  $filter =  'Name = "MicrosoftDynamicsNavServer${0}"' -f $ServiceInstanceName
  $services = Get-WmiObject -Class "Win32_Service" -Filter $filter
  if ((-not $services) -or ($services.Count -ne 1)) {
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
    $changeService = $Service.Change($null,                # DisplayName
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

Export-ModuleMember -Function "New-NAVServiceTier","Set-ServiceCredential"