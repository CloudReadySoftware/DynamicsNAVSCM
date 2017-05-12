Param(
  [Parameter()]
  [String[]]$Modules,
  [Parameter()]
  [String]$SourceDatabaseInstance,
  [Parameter()]
  [String]$SourceDatabaseName,
  [Parameter()]
  [String]$CommonSQLLocation,
  [Parameter()]
  [String]$DestinationDatabaseName
)

foreach($Module in $Modules)
{
  Import-Module $Module -ErrorAction Stop
}

Copy-NAVDatabase -SourceDatabaseInstance $SourceDatabaseInstance -SourceDatabaseName $SourceDatabaseName -CommonSQLLocation $CommonSQLLocation -DestinationDatabaseName $DestinationDatabaseName
Invoke-SQLCmd -Query "EXEC sp_addrolemember 'db_owner', 'NT AUTHORITY\System'" -Database $DestinationDatabaseName -ServerInstance "."