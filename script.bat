@echo OFF

@setlocal enableextensions
@cd /d "%~dp0"

set /p duration="Enter duration (sec): "
set /p sampleInterval="Enter sample interval (sec): "

set folderName=%duration%_%sampleInterval%

md %cd%\%folderName% > nul 2>&1

set startFile=%cd%\%folderName%\%folderName%_start.bat
break > %startFile%
set stopFile=%cd%\%folderName%\%folderName%_stop.bat
break > %stopFile%
set deleteFile=%cd%\%folderName%\%folderName%_delete_groups.bat
break > %deleteFile%
set importFile=%cd%\%folderName%\%folderName%_import_groups.bat
echo @setlocal enableextensions > %importFile%
echo @cd /d "%~dp0%folderName%\" >> %importFile%

set file[0]=Application.Memory
set file[1]=Application.NetworkInterface
set file[2]=Application.PhysicalDisk
set file[3]=Application.Process
set file[4]=Application.Processor
set file[5]=Application.System

setlocal enabledelayedexpansion
for /l %%n in (0,1,5) do (
	
	set outputFile=%folderName%\%folderName%.!file[%%n]!.xml
	break > !outputFile!
	echo !outputFile! created
	
	for /F "delims=" %%G in (Templates\!file[%%n]!.xml) do (
		set LINE=%%G
		set LINE=!LINE:^<Duration^>#####^</Duration^>=^<Duration^>%duration%^</Duration^>!
		set LINE=!LINE:^<SampleInterval^>#####^</SampleInterval^>=^<SampleInterval^>%sampleInterval%^</SampleInterval^>!
		echo !LINE! >> !outputFile!
	) 
	
	logman delete %folderName%.!file[%%n]! > nul
	logman import -name %folderName%.!file[%%n]! -xml !outputFile!
	
	echo logman start %folderName%.!file[%%n]! >> !startFile!
	echo logman stop %folderName%.!file[%%n]! >> !stopFile!
	echo logman delete %folderName%.!file[%%n]! >> !deleteFile!
	echo logman import -name %folderName%.!file[%%n]! -xml %folderName%.!file[%%n]!.xml >> !importFile!
)
endlocal