function Remove-NAVVersionNumber 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$VersionList,
    [Parameter(Mandatory)]
    [String]$VersionToRemove
    )
  Process
  {
    $VersionArray = $VersionList -split ","
    [String[]]$NewVersionArray = foreach($Version in $VersionArray) {
      if(-not ($Version -match $VersionToRemove))
      {
        $Version
      }
    }
    $NewVersionArray -join ","
  }
}

function Add-NAVVersionNumber 
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [String]$VersionList,
    [Parameter(Mandatory)]
    [String]$NewVersionNo
    )
  Process
  {
    if($VersionList -eq "") 
    {
      return $NewVersionNo
    }
    [String[]]$VersionArray = $VersionList -split ","
    $Added = $false
    $SolutionName = $NewVersionNo
    if($NewVersionNo -match "^\D+")
    {
      $SolutionName = $matches[0]
    }
    $NewVersionArray = New-Object "System.Collections.ArrayList"
    foreach($Version in $VersionArray) {
      if($Version -match $SolutionName)
      {
        $Version = $NewVersionNo
        $Added = $true
      }
      $null = $NewVersionArray.Add($Version)
    }
    if(-not $Added)
    {
      $null = $NewVersionArray.Add($NewVersionNo)
    }
    $NewVersionList = $NewVersionArray -join ","
    if($NewVersionList.Length -gt 248) {
      $ErrorMessage = 'The versionlist "{0}" is too long!' -f $NewVersionList
      Write-Warning $ErrorMessage
      return $VersionList
    }
    $NewVersionList
    
  }
}