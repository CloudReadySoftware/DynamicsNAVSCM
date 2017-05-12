function Get-TempFolder 
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [String]$SourceFolder = $env:temp
    )
  Process
  {
    $Foldername = Join-Path $SourceFolder (New-Guid)
    New-Item -Path $Foldername -ItemType Directory
  }
}