#Requires -Modules SQLPS

function Copy-NAVDatabase 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$SourceDatabaseInstance,
    [Parameter(Mandatory)]
    [String]$SourceDatabaseName,
    [Parameter(Mandatory)]
    [String]$CommonSQLLocation,
    [Parameter(Mandatory)]
    [String]$DestinationDatabaseName
    )
  Process
  {
    $null = Test-SQLConnection -ServerInstance $SourceDatabaseInstance -DatabaseName $SourceDatabaseName
    $null = Test-SQLConnection -ServerInstance $env:computername
    Backup-SqlDatabase -BackupAction Files -CopyOnly -ServerInstance $SourceDatabaseInstance -Database $SourceDatabaseName -BackupFile $CommonSQLLocation
    $LogicalFileNames = Get-LogicalFilenames -SQLInstance $SourceDatabaseInstance -Database $SourceDatabaseName
    $NewLocations = Get-SQLFileLocation -TargetSQLInstance $env:computername -TargetDatabase $DestinationDatabaseName -LogicalDataFilename $LogicalFileNames.Data -LogicalLogFilename $LogicalFileNames.Log
    Restore-SqlDatabase -ServerInstance $env:computername -Database $DestinationDatabaseName -BackupFile $CommonSQLLocation -RelocateFile $NewLocations -ReplaceDatabase
    Remove-Item $CommonSQLLocation
  }
}

function Test-SQLConnection 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$ServerInstance,
    [Parameter()]
    [String]$DatabaseName = "master",
    [Parameter()]
    [Int]$ConnectionTimeout = 2
    )
  Process
  {
    $sqlServer = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $ServerInstance
    $dbConnection = New-Object "System.Data.SqlClient.SqlConnection"
    $dbConnection.ConnectionString = "Data Source=$ServerInstance; Database=$DatabaseName;`
                                    Integrated Security=True;Connection Timeout=$ConnectionTimeout"
    try {
      $null = $dbConnection.Open()
      $dbConnection.Close()
      return $true
    } catch {
      throw "Could not establish connection to server: '$ServerInstance', database: '$DatabaseName'"
    }
  }
}

function Get-SQLFileLocation 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$TargetSQLInstance,
    [Parameter(Mandatory)]
    [String]$TargetDatabase,
    [Parameter(Mandatory)]
    [String]$LogicalDataFilename,
    [Parameter(Mandatory)]
    [String]$LogicalLogFilename
    )
  Process
  {
    
    $databaseinstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $TargetSQLInstance
    $logfileName = "{0}_Log.ldf" -f $TargetDatabase
    $dataFilename = "{0}.mdf" -f $TargetDatabase
    $logpath = Join-Path $databaseinstance.Settings.DefaultLog $logfileName
    $datapath = Join-Path $databaseinstance.Settings.DefaultFile $dataFilename

    $DataSQLFileLocation = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($LogicalDataFilename, $datapath)
    $LogSQLFileLocation = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($LogicalLogFilename, $logpath)
    @($DataSQLFileLocation, $LogSQLFileLocation)
  }
}

function Get-LogicalFilenames 
{
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [String]$SQLInstance,
    [Parameter(Mandatory)]
    [String]$Database
    )
  Process
  {
    $databaseInfo = Get-SQLDatabase -ServerInstance $SQLInstance -Name $Database
    [PSCustomObject]@{
      "Data" = $databaseInfo.FileGroups.Files.Name
      "Log" = $databaseInfo.LogFiles.Name
    }
    Write-Output $object
  }
}

Export-ModuleMember -Function "Copy-NAVDatabase"