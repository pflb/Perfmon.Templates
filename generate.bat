@echo OFF

set durationHours=%1
set sampleInterval=%2

if [%1] == [] (
	echo Please rerun script with 2 parameters: duration ^(hours^) and sample interval ^(seconds^).
	pause
	exit /B 1
)
if [%2] == [] (
	echo Please rerun script with 2 parameters: duration ^(hours^) and sample interval ^(seconds^).
	pause
	exit /B 1
)   

set /a durationSeconds=%durationHours%*3600

md %cd%\%durationHours%h 

setlocal enabledelayedexpansion

set startFile=%cd%\%durationHours%h_start.bat
echo. > %startFile%
set stopFile=%cd%\%durationHours%h_stop.bat
echo. > %stopFile%

set file[0]=Application.Memory
set file[1]=Application.NetworkInterface
set file[2]=Application.PhysicalDisk
set file[3]=Application.Process
set file[4]=Application.Processor
set file[5]=Application.System

for /l %%n in (0,1,5) do (
	
	set outputFile=%durationHours%h\%durationHours%h.!file[%%n]!.xml
	break > !outputFile!
	echo !outputFile! created
	
	for /F "delims=" %%G in (Templates\!file[%%n]!.xml) do (
		set LINE=%%G
		set LINE=!LINE:^<Duration^>#####^</Duration^>=^<Duration^>%durationSeconds%^</Duration^>!
		set LINE=!LINE:^<SampleInterval^>#####^</SampleInterval^>=^<SampleInterval^>%sampleInterval%^</SampleInterval^>!
		echo !LINE! >> !outputFile!
	) 
	
	logman delete %durationHours%h.!file[%%n]! > nul
	logman import -name %durationHours%h.!file[%%n]! -xml !outputFile!
	
	echo logman start %durationHours%h.!file[%%n]! >> !startFile!
	echo logman stop %durationHours%h.!file[%%n]! >> !stopFile!
)




endlocal