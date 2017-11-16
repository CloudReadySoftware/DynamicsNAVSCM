function Export-IDENAVObject 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$DatabaseName,
    [Parameter(Mandatory)]
    [String]$DestinationFolder,
    [Parameter()]
    [String]$TempFolder,
    [Parameter()]
    [String[]]$Filters,
    [Parameter()]
    [Boolean]$DateModification
    )
  Process
  {
    $NewTempFolder = Get-TempFolder -SourceFolder $TempFolder
    $SplitFolder = Join-Path $NewTempFolder "split"
    Export-SplitTextFile -DatabaseName $DatabaseName -DestinationFolder $SplitFolder -TempFolder $NewTempFolder -Filters $Filters
    Update-NAVObjectProperties -ExportedFiles $SplitFolder -OriginalFiles $DestinationFolder -DateModification $DateModification
    Copy-UpdatedObjects -SourceFolder $SplitFolder -DestinationFolder $DestinationFolder
    Reset-UnlicensedObjects -ObjectFolder $DestinationFolder
    Sync-NAVObjectFiles -ObjectFolder $DestinationFolder -DatabaseName $DatabaseName
    Remove-Item $NewTempFolder -Recurse -Force
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
    if($Objects) {
      Remove-Item $Objects
    }
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
    [Parameter()]
    [String]$TempFolder,
    [Parameter()]
    [String[]]$Filters = @('')
  )
  [int]$count = 0
  foreach($Filter in $Filters) {
    $count += 1
    $foldername = Join-Path $TempFolder "export$count"
    $folder = New-Item -Path $Foldername -ItemType Directory
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
    [Parameter()]
    [Boolean]$DateModification = $false
  )
    if(!$DateModification) {
      return
    }
    $ExportedObjects = Get-ChildItem $ExportedFiles
    foreach($ExportedObject in $ExportedObjects)
    {
      $OrignalObject = Join-Path $OriginalFiles $ExportedObject.Name
      $DateValue = Get-Date -Hour 0 -Minute 30 -Second 0
      if(Test-Path -Path $OrignalObject -PathType Leaf)
      {
        $OrignalInfo = Get-NAVApplicationObjectProperty -Source $OrignalObject
        $DateValue = "{0} {1}" -f $OrignalInfo.Date,$OrignalInfo.Time
      }
      $DateTimeProp = Get-Date -Date $DateValue -Format "G"
      Set-NAVApplicationObjectProperty -TargetPath $ExportedObject.FullName -DateTimeProperty $DateTimeProp
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
    if($result.FileDeleteList -ne $null) {
      Remove-Item $result.FileDeleteList
    }
    if($result.DatabaseDeleteList -ne $null) {
      Export-FobFiles -DatabaseName $DatabaseName -DatabaseObjects $result.DatabaseDeleteList -ObjectFolder $ObjectFolder
    }
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