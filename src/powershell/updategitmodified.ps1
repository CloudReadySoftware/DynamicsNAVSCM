#Update Modified based on Original and Delta
Remove-Item (join-path $ModifiedDestination '*.TXT')
Update-NAVApplicationObject -TargetPath $SourceDestination -DeltaPath $DeltaDesitination -ResultPath $ModifiedDestination