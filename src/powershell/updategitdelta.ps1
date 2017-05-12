#Update the Delta folder based on Original and Modified
Remove-Item (join-path $DeltaDestination '*.DELTA')
Compare-NAVApplicationObject -OriginalPath $SourceDestination -ModifiedPath $ModifiedDestination -DeltaPath $DeltaDesitination -ErrorAction Stop