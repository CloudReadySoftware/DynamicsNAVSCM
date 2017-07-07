
function Export-FOB
{
  [CmdletBinding()]
  Param(    
    )
  Process
  {
    throw "STILL TODO!"
    #Export fob file with filter saying all objects with the same versionnumber as the current one. 
    $fobFile = Join-Path $NAVRepo "Export.fob" 
    Export-NAVApplicationObject -DatabaseName $NAVDatabaseName -Path $fobFile -Filter "Version List=@*$NAVSolutionName*"
  }
}

function Export-IDENAVObject 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$DatabaseName,
    [Parameter(Mandatory)]
    [String]$DestinationFolder,
    [Parameter(Mandatory)]
    [String]$SolutionName,
    [Parameter(Mandatory)]
    [String]$NextVersionTag,
    [Parameter(Mandatory)]
    [String[]]$ExportFilters
    )
  Process
  {
    $ExportedFolder = Get-TempFolder
    Export-SplitTextFile -DatabaseName $DatabaseName -DestinationFolder $ExportedFolder -ExportFilters $ExportFilters
    Update-NAVObjectProperties -ExportedFiles $ExportedFolder -OriginalFiles $DestinationFolder -NextVersionTag $NextVersionTag
    Copy-UpdatedObjects -SourceFolder $ExportedFolder -DestinationFolder $DestinationFolder
    Reset-UnlicensedObjects -ObjectFolder $DestinationFolder
    Sync-NAVObjectFiles -DestinationFolder $DestinationFolder -DatabaseName $DatabaseName
    Remove-Item $ExportedFolder -Recurse -Force
    $IdeResultFolder = Join-Path $env:TEMP 'NavIde'
    Remove-Item $IdeResultFolder -Recurse
  }
}

function Reset-UnlicensedObjects
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ObjectFolder
  )
  Process
  {
    $Objects = Get-ChildItem $ObjectFolder -Include "*.fob"
    Remove-Item $Objects
  }
}

function Copy-UpdatedObjects
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$SourceFolder,
    [Parameter(Mandatory)]
    [String]$DestinationFolder
  )
  Process
  {
    $UpdatedObjects = Get-ChildItem $SourceFolder
    if(-not ($UpdatedObjects)) {
      return
    }
    if(-not (Test-Path $DestinationFolder)) {
      $null = New-Item -Path $DestinationFolder -ItemType Directory
    }
    $UpdatedFiles = $UpdatedObjects | Select-Object -ExpandProperty "FullName"
    Copy-Item -Path $UpdatedFiles -Destination $DestinationFolder -Force
  }
}

function Export-SplitTextFile  
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$DatabaseName,
    [Parameter(Mandatory)]
    [String]$DestinationFolder,
    [Parameter(Mandatory)]
    [String[]]$ExportFilters
  )
  foreach($Filter in $ExportFilters) {
    
    $folder = Get-TempFolder
    $txtFile = Join-Path $folder "export.txt" 
    $txtFile = Export-NAVApplicationObject -DatabaseName $DatabaseName -Path $txtFile -ExportTxtSkipUnlicensed -Filter $Filter
    if(Test-Path $txtFile) {
      $File = Get-Item $txtFile
      if($File.Length -ne 0){
        Split-NAVApplicationObjectFile -Source $txtFile -Destination $DestinationFolder -PreserveFormatting -Force
      }
    }
    Remove-Item $folder -Recurse
  }
}

function Update-NAVObjectProperties {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ExportedFiles,
    [Parameter(Mandatory)]
    [String]$OriginalFiles,
    [Parameter(Mandatory)]
    [String]$NextVersionTag
  )
    $modifiedObjects = Get-ChildItem $ExportedFiles
    foreach($modifiedObject in $modifiedObjects)
    {
      $OrignalFile = Join-Path $OriginalFiles $modifiedObject.Name
      $CurrentVersionList = ""
      $DateValue = Get-Date -Hour 0 -Minute 30 -Second 0
      if(Test-Path -Path $OrignalFile -PathType Leaf)
      {
        $OrignalInfo = Get-NAVApplicationObjectProperty -Source $OrignalFile
        $DateValue = "{0} {1}" -f $OrignalInfo.Date,$OrignalInfo.Time
        $CurrentVersionList = $OrignalInfo.VersionList
      }
      $DebugInfo = 'CurrentFile: "{3}" CurrentVersionList: "{0}", NextVersionTag: "{1}" OriginalFile: "{2}"' -f $CurrentVersionList, $NextVersionTag, $OrignalFile, $modifiedObject.Name
      Write-Debug $DebugInfo
      $NewVersionList = Add-NAVVersionNumber -VersionList $CurrentVersionList -NewVersionNo $NextVersionTag
      $DateTimeProp = Get-Date -Date $DateValue -Format "G"
      Set-NAVApplicationObjectProperty -TargetPath $modifiedObject.FullName -DateTimeProperty $DateTimeProp -ModifiedProperty "No" -VersionListProperty $NewVersionList
    }
}

function Sync-NAVObjectFiles
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ObjectFolder,
    [Parameter(Mandatory)]
    [String]$DatabaseName
    )
  Process
  {
    $objectFiles = Join-Path $ObjectFolder "*.txt"
    $currentFiles = Get-ChildItem $objectFiles
    $databaseObjects = Get-NAVDatabaseObjects -DatabaseName $DatabaseName
    $result = Compare-NAVExportObjects -FileList $currentFiles -DatabaseList $databaseObjects
    Remove-Item $result.FileDeleteList
    Export-FobFiles -DatabaseName $DatabaseName -DatabaseObjects $result.DatabaseDeleteList -ObjectFolder $ObjectFolder
  }
}

function Export-FobFiles
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$Databasename,
    [Parameter(Mandatory)]
    [PSCustomObject[]]$DatabaseObjects,
    [Parameter(Mandatory)]
    [String]$ObjectFolder
  )
  Process
  {
    foreach($DatabaseObject in $DatabaseObjects)
    {
      $Filename = "{0}.fob" -f $DatabaseObject.FileName      
      $Path = Join-Path $ObjectFolder $Filename
      $Filter = "Type={0};ID={1}" -f $DatabaseObject.Type,$DatabaseObject.ID
      $null = Export-NAVApplicationObject -DatabaseName $DatabaseName -Path $Path -Filter $Filter
    }
  }
}


function Compare-NAVExportObjects 
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [System.IO.FileInfo[]]$FileList,
    [Parameter()]
    [PSCustomObject[]]$DatabaseList
    )
  Process
  {
    $FileBaseNameArray = $FileList.BaseName
    $DatabaseListNameArray = $DatabaseList.FileName
    $FileObjectSet = [System.Collections.Generic.HashSet[String]]$FileBaseNameArray
    $FileObjectSet_dup = [System.Collections.Generic.HashSet[String]]$FileBaseNameArray
    $databaseObjectSet = [System.Collections.Generic.HashSet[String]]$DatabaseListNameArray
    $FileObjectSet.ExceptWith($databaseObjectSet)
    $databaseObjectSet.ExceptWith($FileObjectSet_dup)

    $FileToDelete = $FileList | Where-Object {$FileObjectSet -contains $PSItem.BaseName}
    $DatabaseToExport = $DatabaseList | Where-Object {$databaseObjectSet -contains $PSItem.FileName}

    [PSCustomObject]@{
      "FileDeleteList" = $FileToDelete
      "DatabaseDeleteList" = $DatabaseToExport
    }
  }
}

function Get-NAVDatabaseObjects 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$DatabaseName
    )
  Process
  {
    $Query = "SELECT
                [Type],
                [ID],
                UPPER(SUBSTRING([Type], 1, 3)) + [ID] as [FileName]
              FROM 
              (
                SELECT 
                  CASE [Type] 
                    WHEN 1 THEN 'Table' 
                    WHEN 3 THEN 'Report' 
                    WHEN 5 THEN 'Codeunit' 
                    WHEN 6 THEN 'XMLport' 
                    WHEN 7 THEN 'MenuSuite' 
                    WHEN 8 THEN 'Page' 
                    WHEN 9 THEN 'Query' 
                END as 'Type',
                  CAST([ID] as VARCHAR) as [ID]
                FROM
                  [Object]
                WHERE 
                  [Type] != 0 AND
                  [Compiled] = 1
              ) as [a]
              ORDER BY
                [FileName]"
    $datarows = Invoke-Sqlcmd -Query $Query -Database $DatabaseName
    foreach($row in $datarows){
      [PSCustomObject]@{
        'Type' = $row.Type
        'ID' = $row.ID
        'FileName' = $row.FileName
      }
    }
  }
}

Export-ModuleMember -Function "Export-IDENAVObject","Export-FOB"