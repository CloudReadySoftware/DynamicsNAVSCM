#Requires -Modules Microsoft.Dynamics.Nav.Ide,Microsoft.Dynamics.Nav.Model.Tools


function Import-IDENAVObject
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ObjectsFolder,
    [Parameter(Mandatory)]
    [String]$Workspacefolder,
    [Parameter(Mandatory)]
    [String]$SolutionName,
    [Parameter(Mandatory)]
    [String]$DatabaseName,
    [Parameter(Mandatory)]
    [String]$LastImportGitHashFilepath
    )
  Process
  {
    Push-Location $Workspacefolder
    if(-not (Test-GitInstalled)) {
      throw "Git not installed? Cannot be used."
    }
    $CurrentHash = Get-CurrentGitHash
    $Foldername = Split-Path $ObjectsFolder -Leaf
    $files = Get-GitImportObjects -LastImportGitHashFilepath $LastImportGitHashFilepath -CurrentHash $CurrentHash -Foldername $Foldername
    $tempfolder = Get-TempFolder
    $SingleFile = Join-Path $tempfolder "file.txt"
    $null = Join-NAVApplicationObjectFile -Source $files -Destination $SingleFile
    Import-NAVApplicationObject -Path $SingleFile -DatabaseName $DatabaseName -ImportAction "Overwrite" -SynchronizeSchemaChanges "No" -Confirm:$false
    Remove-Item $tempfolder -Recurse -Force
    Sync-NAVDatabaseObjects
    Set-LastImportedGitHash -GitHash $CurrentHash -File $LastImportGitHashFilepath
  }
}


function Sync-NAVDatabaseObjects 
{
  [CmdletBinding()]
  Param(
    )
  Process
  {
    $objectFiles = Join-Path $ObjectsFolder "*.txt"
    $currentFiles = Get-ChildItem $objectFiles
    $databaseObjects = Get-NAVDatabaseObjects
    $basenames = $currentFiles.BaseName
    foreach($databaseObject in $databaseObjects)
    {
      if(-not ($basenames -contains $databaseObject))
      {
        $Object = Convert-NAVObjectFileName -FileName $databaseObject
        $Filter = "Type={0};Id={1}" -f $Object.Type,$Object.ID
        Delete-NAVApplicationObject -DatabaseName $NAVDatabaseName -Filter $Filter -SynchronizeSchemaChanges "No" -Confirm:$false
      }
    }
  }
}

function Convert-NAVObjectFileName 
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [String]$FileName
    )
  Process
  {
    switch ($FileName.SubString(0, 3))
    {
      "COD" {$Type = "Codeunit"}
      "MEN" {$Type = "Menusuite"}
      "PAG" {$Type = "Page"}
      "QUE" {$Type = "Query"}
      "REP" {$Type = "Report"}
      "TAB" {$Type = "Table"}
      "XML" {$Type = "XMLport"}
      default { throw "Unknown type!"}
    }
    [PSCustomObject]@{
      "Type" = $Type
      "ID" = $FileName.SubString(3)
    }
  }
}

function Get-GitImportObjects
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$LastImportGitHashFilepath,
    [Parameter(Mandatory)]
    [String]$CurrentHash,
    [Parameter(Mandatory)]
    [String]$Foldername
  )
  Process
  {
    $hash = Get-LastImportedHash -File $LastImportGitHashFilepath
    Get-DiffInObjects -LastImportedHash $hash -CurrentHash $CurrentHash -Foldername $Foldername
  }
}

function Get-CurrentGitHash
{
  [CmdletBinding()]
  Param(
  )
  Process
  {
    Invoke-Expression -Command "git rev-parse HEAD"
  }
}

function Get-LastImportedHash
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$File
  )
  Process
  {
    $result = ""
    if(Test-Path -PathType Leaf $File) {
      $result = Get-Content $file
    } else {
      $result = Invoke-Expression "git rev-list --max-parents=0 HEAD"
    }
    $result
  }
}

function Test-GitInstalled
{
  [CmdletBinding()]
  Param(
  )
  Process
  {
    $command = "git status"
    $result = $true
    try {
      $response = Invoke-Expression -Command $command

    } catch {
      $result = $false
    }
    $result
  }
}

function Get-DiffInObjects
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [String]$LastImportedHash,
    [Parameter(Mandatory)]
    [String]$CurrentHash,
    [Parameter(Mandatory)]
    [String]$Foldername
  )
  Process
  {
    $command = 'git diff --name-only "{0}" "{1}"' -f $LastImportedHash, $CurrentHash
    $result = Invoke-Expression -Command $command 
    $regex = '^{0}/.*\.txt$' -f $Foldername
    $resultObjects = $result | Where-Object {$PSItem -imatch $regex}
    $currentpath = Get-Location
    $currentPath = $currentpath.Path
    foreach($object in $resultObjects) {
      Join-Path $currentpath $object
    }
  }
}

function Set-LastImportedGitHash
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$GitHash,
    [Parameter(Mandatory)]
    [String]$File
  )
  Process
  {
    Out-File -FilePath $File -Encoding utf8 -NoNewline -InputObject $GitHash
  }
}

Export-ModuleMember -Function "Import-IDENAVObject"