$templates = "Application.Memory", "Application.NetworkInterface", "Application.PhysicalDisk", "Application.Process", "Application.Processor", "Application.System"

$Duration = 3600
$SampleInterval = 30
$TemplatesPath = "D:\Project\Perfmon.Templates\Templates"


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
$TemplatesPathTextBox.add_TextChanged( { $SampleInterval = $TemplatesPathTextBox.Text })
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

Function ImportDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $templateName = $TemplatesPath + "\" + $template + ".xml"
        $xml = get-content $templateName
        $newDuration = "<Duration>"+$Duration+"</Duration>"
        $newSampleInterval = "<SampleInterval>"+$SampleInterval+"</SampleInterval>"
        $xml = $xml -replace "<Duration>#####</Duration>", $newDuration
        $xml = $xml -replace "<SampleInterval>#####</SampleInterval>", $newSampleInterval
        $datacollectorset.SetXml($xml)
        $datacollectorset.Commit($template , $null , 0x0003) 
    }
}

Function StartDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $datacollectorset.Query($template,$null)
        $datacollectorset.start($false)
    }
}

Function StopDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $datacollectorset.Query($template,$null)
        $datacollectorset.stop($false)
    }
}

Function DeleteDataSet {
    
    foreach ($template in $templates)
    {
        $datacollectorset = new-object -COM Pla.DataCollectorSet
        $datacollectorset.Query($template,$null)
        $datacollectorset.delete
    }
}