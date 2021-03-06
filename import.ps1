$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent


Function StartApp
{
Add-Type -AssemblyName System.Windows.Forms

$Duration = 3600
$SampleInterval = 30
$TemplatesPath = $scriptPath + "\Templates"

$templates = Get-ChildItem $TemplatesPath -recurse |
    Where-Object { ($_.PSIsContainer -eq $false) -and  ($_.Extension -eq ".xml") }
    

$Win = New-Object System.Windows.Forms.Form
$Win.StartPosition  = "CenterScreen"
$Win.Text = "Импорт наборов счётчиков из шаблонов"
$Win.Width = 600
$Win.Height = 480
$Win.ControlBox = 1

$DurationLabel = New-Object System.Windows.Forms.Label
$DurationTextBox = New-Object System.Windows.Forms.TextBox

$SampleIntervalLabel = New-Object System.Windows.Forms.Label
$SampleIntervalTextBox = New-Object System.Windows.Forms.TextBox

$TemplatesPathLabel = New-Object System.Windows.Forms.Label
$TemplatesPathTextBox = New-Object System.Windows.Forms.TextBox


$DurationLabel.Location     = New-Object System.Drawing.Point(10,10)
$DurationLabel.Text         = "Duration"
$DurationLabel.Autosize     = 1

$DurationTextBox.Location       = New-Object System.Drawing.Point(100,10)
$DurationTextBox.Text           = $Duration
$DurationTextBox.add_TextChanged( { $Duration = $DurationTextBox.Text })
$DurationTextBox.Width          = 300
$DurationTextBox.TabIndex       = 1

$SampleIntervalLabel.Location     = New-Object System.Drawing.Point(10,40)
$SampleIntervalLabel.Text         = "SampleInterval"
$SampleIntervalLabel.Autosize     = 1

$SampleIntervalTextBox.Location       = New-Object System.Drawing.Point(100,40)
$SampleIntervalTextBox.Text           = $SampleInterval
$SampleIntervalTextBox.add_TextChanged( { $SampleInterval = $SampleIntervalTextBox.Text })
$SampleIntervalTextBox.Width          = 300
$SampleIntervalTextBox.TabIndex       = 2

$TemplatesPathLabel.Location     = New-Object System.Drawing.Point(10,70)
$TemplatesPathLabel.Text         = "Templates path"
$TemplatesPathLabel.Autosize     = 1

$TemplatesPathTextBox.Location       = New-Object System.Drawing.Point(100,70)
$TemplatesPathTextBox.Text           = $TemplatesPath
$TemplatesPathTextBox.add_TextChanged( {
    $TemplatesPath = $TemplatesPathTextBox.Text ;
    $templates = Get-ChildItem $TemplatesPath -recurse |
    Where-Object { ($_.PSIsContainer -eq $false) -and  ($_.Extension -eq ".xml") } 
})
$TemplatesPathTextBox.Width          = 300
$TemplatesPathTextBox.TabIndex       = 2

$WinImportButton = New-Object System.Windows.Forms.Button
$WinImportButton.Location     = New-Object System.Drawing.Point(10,110)
$WinImportButton.add_click({ ImportDataSet })
$WinImportButton.Text = "Импорт"

$WinStartButton = New-Object System.Windows.Forms.Button
$WinStartButton.Location     = New-Object System.Drawing.Point(10,140)
$WinStartButton.add_click({ StartDataSet })
$WinStartButton.Text = "Старт"

$WinStopButton = New-Object System.Windows.Forms.Button
$WinStopButton.Location     = New-Object System.Drawing.Point(10,170)
$WinStopButton.add_click({ StopDataSet })
$WinStopButton.Text = "Стоп"

$WinDeleteButton = New-Object System.Windows.Forms.Button
$WinDeleteButton.Location     = New-Object System.Drawing.Point(10,200)
$WinDeleteButton.add_click({ DeleteDataSet })
$WinDeleteButton.Text = "Удалить"


$Win.Controls.Add($DurationLabel)
$Win.Controls.Add($DurationTextBox)

$Win.Controls.Add($SampleIntervalLabel)
$Win.Controls.Add($SampleIntervalTextBox)

$Win.Controls.Add($TemplatesPathLabel)
$Win.Controls.Add($TemplatesPathTextBox)

$Win.Controls.Add($WinImportButton)
$Win.Controls.Add($WinStartButton)
$Win.Controls.Add($WinStopButton)
$Win.Controls.Add($WinDeleteButton)

$Win.ShowDialog() | Out-Null

}

Function WaitStatus($dcs, $status) {
	$maxTryCount = 5
    while($datacollectorset.Status -ne $status -and $maxTryCount -gt 0)
    {
        Start-Sleep 1
		$maxTryCount = $maxTryCount - 1
    }
}

Function ImportDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $xml = get-content $template.FullName
        $newDuration = "<Duration>"+$Duration+"</Duration>"
        $newSampleInterval = "<SampleInterval>"+$SampleInterval+"</SampleInterval>"
        $xml = $xml -replace "<Duration>#####</Duration>", $newDuration
        $xml = $xml -replace "<SampleInterval>#####</SampleInterval>", $newSampleInterval
        $datacollectorset.SetXml($xml)
        $datacollectorset.Commit($template.BaseName , $null , 0x0003) 
    }
    $oReturn=[System.Windows.Forms.Messagebox]::Show("Templates were imported")
}

Function GetXmlFilesFromPath($BasePath) {
    Get-ChildItem $BasePath -recurse | 
        Where-Object {(($_.PSIsContainer -eq $false) -or (($_.PSIsContainer -eq $true) -and ($_.GetFiles().Count -gt 0)))} | 
        Select-Object FullName
}

Function StartDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $datacollectorset.Query($template.BaseName,$null)
        $datacollectorset.start($false)
    }
    $oReturn=[System.Windows.Forms.Messagebox]::Show("Templates were started")
}

Function StopDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $datacollectorset.Query($template.BaseName,$null)
        if ($datacollectorset.Status -ne 0) {
            $datacollectorset.stop($false)
		}
    }
	$isAllStop = $false
	do
	{
		$isAllStop = $true
		foreach ($template in $templates)
		{
			try {
				$datacollectorset = new-object -COM Pla.DataCollectorSet
				$datacollectorset.Query($template.BaseName,$null)
				if ($datacollectorset.Status -ne 0) {
					$isAllStop = $false
				}
			}
            Finally {
            }
		}
		if($isAllStop -ne $true) {
			Start-Sleep 1
		}
	}
	while($isAllStop -ne $true)
    $oReturn=[System.Windows.Forms.Messagebox]::Show("Templates were stopped")
}



Function DeleteDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $datacollectorset.Query($template.BaseName,$null)
        if ($datacollectorset.Status -ne 0) {
            $datacollectorset.stop($false)
            WaitStatus($datacollectorset, 0)
        }        
        $datacollectorset.Delete()
    }
    $oReturn=[System.Windows.Forms.Messagebox]::Show("Templates were deleted
C’est la vie, mon chéri")
}

StartApp;