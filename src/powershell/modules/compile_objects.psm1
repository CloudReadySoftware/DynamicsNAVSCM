function Start-IDECompileNAVObject 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String[]]$Modules,
    [Parameter(Mandatory)]
    [String]$NAVIDE,
    [Parameter(Mandatory)]
    [String]$DatabaseName,
    [Parameter(Mandatory)]
    [Switch]$Background
    )
  Process
  {
    if($Background)
    {
      Start-BackgroundCompile -Modules $Modules -NAVIDE $NAVIDE -DatabaseName $DatabaseName
    }
    else 
    {
      Start-CompileNAVObjects -DatabaseName $DatabaseName
    }
  }
}

function Start-BackgroundCompile 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String[]]$Modules,
    [Parameter(Mandatory)]
    [String]$NAVIDE,
    [Parameter(Mandatory)]
    [String]$DatabaseName
    )
  Process
  {
    $scriptfolder = Split-Path $PSScriptRoot
    $ScriptFile = Join-Path $scriptfolder "compile_obj.ps1"

    $ModulesParameter = '-Modules "{0}"' -f ($Modules -join '","')
    $NAVIDEParameter = '-NAVIDE "{0}"' -f $NAVIDE
    $DatabaseNameParameter = '-DatabaseName "{0}"' -f $DatabaseName
    $ForegroundParameter = '-Foreground'
    $File = '-File {0}' -f $ScriptFile
    Start-Process "powershell.exe" -ArgumentList "-NoProfile",$File,$ModulesParameter,$NAVIDEParameter,$DatabaseNameParameter,$ForegroundParameter -WindowStyle Hidden #Normal/Hidden
  }
} 

function Start-CompileNAVObjects 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$DatabaseName
    )
  Process
  {
    $objectTypes = 'Table','Page','Report','Codeunit','Query','XMLport','MenuSuite'
    $jobs = @()
    foreach($objectType in $objectTypes)
    {
      $filter = "Type=$objectType"
      $jobs += Compile-NAVApplicationObject $DatabaseName -Filter $filter -Recompile -SynchronizeSchemaChanges "No" -AsJob
    }
    Receive-Job -Job $jobs -Wait
    Compile-NAVApplicationObject $DatabaseName -Filter "Modified=1" -Recompile -SynchronizeSchemaChanges "No"
    Compile-NAVApplicationObject $DatabaseName -SynchronizeSchemaChanges "No"

    Remove-Item (Join-Path $env:temp "NAVIDE") -Recurse -Force
  }
}

Export-ModuleMember -Function "Start-IDECompileNAVObject","Start-CompileNAVObjets"
