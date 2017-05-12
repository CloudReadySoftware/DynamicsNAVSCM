Param(
 [Parameter(Mandatory)]
  [String[]]$Modules,
  [Parameter(Mandatory)]
  [string]$InitialDirectory
)  

foreach($Module in $Modules)
{
  Import-Module $Module -ErrorAction Stop
}

OpenFileDialog -Title "Select ZIP Build file" -InitialDirectory $InitialDirectory -Filter "Zipfile (*.zip)|*.zip"
