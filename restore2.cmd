@echo off
setlocal

REM 10/26/2021 - version 2.1

REM if system drive mounts on other than C: location, change the next line to point to correct drive letter
Set _drv=c:
Set _sys=%_drv%\Windows
pushd %_sys%\WinSxS

echo running disk check
chkdsk %_drv% /f /x /v

for /f %%a in ('dir /s /b svchost.exe') do call :replace %%a

echo running system files scan
sfc /scannow /offbootdir=%_drv%\ /offwindir=%_sys% /OFFLOGFILE=%_drv%\log.txt

goto :eof

REM ===========================================
:replace

Set _loc=
echo SxS file: %~1
echo %~1 | find /i "amd64" >nul
if NOT errorlevel 1 Set _loc=System32
echo %~1 | find /i "wow64" >nul
if NOT errorlevel 1 Set _loc=SysWOW64
rem check if file is not one we are looking for, skip...
if "%_loc%"=="" goto :eof

echo SxS size: %~z1 Timestamp: %~t1

echo Copy to: %_sys%\%_loc%

for /f %%b in ("%_sys%\%_loc%\svchost.exe") do (
    set _badsz=%%~zb
    set _baddt=%%~tb
)
echo System size: %_badsz% Timestamp: %_baddt%
REM If %~z1 EQU %_badsz% If "%~t1" EQU "%_baddt%" goto :replace
If %~z1 EQU %_badsz% (
	echo replacing file: %_sys%\%_loc%\svchost.exe
	ren %_sys%\%_loc%\svchost.exe svchost.bak
	copy %~1 %_sys%\%_loc%\svchost.exe
) ELSE (
    echo File to be replaced either not found or not matching - please troubleshoot manually!
)

echo.
goto :eof
