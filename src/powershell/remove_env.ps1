#Requires -RunAsAdministrator

Param(
  [Parameter(Mandatory)]
  [String]$ServiceInstanceName,
  [Parameter(Mandatory)]
  [String]$BaseFolder
)
Write-Host $ServiceInstanceName
$ServiceNameFilter = 'Name = "{0}"' -f $ServiceInstanceName
Write-Host $ServiceNameFilter
$service = Get-WmiObject win32_service -Filter $ServiceNameFilter
$MultipleServices = $false
if($service) 
{
  $MultipleServices = [bool](Get-Member -InputObject $service -Name 'Count' -MemberType Properties)
}
if ($MultipleServices) {
  throw "Not specific enough"
}
if ($service) {
  if ($service.State -eq 'Running') {
    Stop-Service -Name $service.Name -NoWait
  }
  $null = $service.Delete()
  Start-Sleep -Milliseconds 500
}

if(Test-Path $BaseFolder)
{
  Remove-Item $BaseFolder -Force -Recurse -ErrorAction 'SilentlyContinue'
  Start-Sleep -Milliseconds 500
  if(Test-Path $BaseFolder) 
  {
    Remove-Item $BaseFolder -Force -Recurse -ErrorAction 'SilentlyContinue'
  }
}