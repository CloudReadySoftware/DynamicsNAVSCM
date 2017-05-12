Function OpenFileDialog
{
    param(
        [Parameter()]
        [String]$Title = "Open File",
        [Parameter()]
        [String]$InitialDirectory,
        [Parameter()]
        [String]$Filter = "All Files (*.*)|*.*"
    )

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Title = $Title
    $OpenFileDialog.InitialDirectory = $InitialDirectory
    $OpenFileDialog.Filter = $Filter
    $null = $OpenFileDialog.ShowDialog()
    $OpenFileDialog.FileName
}

Function ConfirmDialog
{
    param(
        [string]$title="Confirm",
        [string]$message="Are you sure?"
    )
	
    $choiceYes = New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Answer Yes.'
    $choiceNo = New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Answer No.'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($choiceYes, $choiceNo)
    $result = $host.ui.PromptForChoice($title, $message, $options, 1)
	
    switch ($result)
    {
		0 
		{
		Return $true
		}
 
		1 
		{
		Return $false
		}
	}
}