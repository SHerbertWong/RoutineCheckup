@ECHO OFF

SET "CmdScriptRoot=%~dp0"
SET "CmdScriptPath=%~f0"

SET "BootStrapperUri=https://raw.githubusercontent.com/SHerbertWong/RoutineCheckup/master/Start-RoutineCheckupBootstrapping.ps1"
SET "BootStrapperFunctionName=Start-RoutineCheckupBootStrapping"
SET "BootStrapperFileName=%BootStrapperFunctionName%.ps1"
SET "WgetUri=https://onedrive.live.com/download?cid=63B88D4120E75E9C&resid=63B88D4120E75E9C%211335&authkey=AB1YzjkM8DwpMOc"
SET "WgetFileName=wget.exe"

FOR /F "tokens=* USEBACKQ" %%f IN (`POWERSHELL -ExecutionPolicy Bypass -Command "Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetFileNameWithoutExtension([IO.Path]::GetRandomFileName()))"`) DO (SET "RoutineCheckupRootPath=%%f")
MD "%RoutineCheckupRootPath%"
SET "PATH=%RoutineCheckupRootPath%;%PATH%"
POWERSHELL -ExecutionPolicy Bypass -Command ^
	"Write-Host -Object 'Downloading %WgetFileName%... ' -NoNewline; (New-Object -TypeName Net.WebClient).DownloadFile('%WgetUri%', (Join-Path -Path '%RoutineCheckupRootPath%' -ChildPath '%WgetFileName%')); Write-Host -Object 'Done!'"
POWERSHELL -ExecutionPolicy Bypass -Command ^
	"Write-Host -Object 'Downloading %BootStrapperFileName%... ' -NoNewline; (New-Object -TypeName Net.WebClient).DownloadFile('%BootStrapperUri%', (Join-Path -Path '%RoutineCheckupRootPath%' -ChildPath '%BootStrapperFileName%')); Write-Host -Object 'Done!'"
START POWERSHELL -ExecutionPolicy Bypass -Command ^
 	". '%RoutineCheckupRootPath%\%BootStrapperFileName%'; %BootStrapperFunctionName% -RootPath '%RoutineCheckupRootPath%'"

(GOTO) 2> NUL & DEL /Q "%CmdScriptPath%" 2> NUL
