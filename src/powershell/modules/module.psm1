function Test-NAVFile 
{
  [CmdletBinding()]
  Param(
    [Parameter()]
    [String]$Path
    )
  Process
  {
    if(-not (Test-Path $Path -Pathtype Leaf))
    {
      throw ("Missing the file '{0}'" -f $Path)
    }
  }
}

function Complete-NAVVersioning 
{
  [CmdletBinding()]
  Param(
    )
  Process
  {
    #NO EXPORT FIRST! IMPORTANT
    #Import-AllObjects
    #Compile all objects
    #Export solutionname
    $Filename = "{0}.fob" -f $NAVSolutionVersion
    $FilePath = Join-Path $NAVRepo $FileName
    if(Test-Path $FilePath)
    {
      Remove-Item $FilePath
    }
    Export-NAVApplicationObject -DatabaseName $NAVDatabaseName -Path $fobFile -Filter "Version List=@*$NAVSolutionName*"
  }
}

function Create-FolderIfNotExist
{
    [CmdletBinding()]
    param (
        [String]$MyFolder
          )

    if ( -Not (Test-Path $MyFolder)) 
    {
        New-Item $MyFolder -type directory
    }

}

function Remove-FolderIfExist
{
    [CmdletBinding()]
    param (
        [String]$MyFolder
          )
    if (Test-Path $MyFolder) 
    {
        Remove-Item $MyFolder -Recurse
    }
}
