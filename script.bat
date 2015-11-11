@echo OFF

set durationHours=%1
set sampleInterval=%2

set /a durationSeconds=%durationHours%*3600

md %cd%\%durationHours%h

setlocal enabledelayedexpansion

set file[0]=Application.Memory
set file[1]=Application.NetworkInterface
set file[2]=Application.PhysicalDisk
set file[3]=Application.Process
set file[4]=Application.Processor
set file[5]=Application.System

for /l %%n in (0,1,5) do (
	
	set outputFile=%durationHours%h\%durationHours%h.!file[%%n]!.xml
	echo !outputFile! created
	
	for /F "delims=" %%G in (Templates\!file[%%n]!.xml) do (
		set LINE=%%G
		if not "!LINE!" == "!LINE:Duration=!" (
			set LINE=!LINE:#####=%durationSeconds%!
		)
		if not "!LINE!" == "!LINE:SampleInterval=!" (
			set LINE=!LINE:#####=%sampleInterval%!
		)
		echo !LINE! >> !outputFile!
	) 
	
	logman import -name %durationHours%h.!file[%%n]! -xml !outputFile!
)

endlocal