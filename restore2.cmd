@echo off
setlocal

REM if system drive mounts on other than C: location, change the next line to point to correct drive letter
Set _drv=c:
Set _sys=%_drv%\Windows
pushd %_sys%\WinSxS

for /f %%a in ('dir /s /b svchost.exe') do call :replace %%a

echo running disk check
chkdsk %_drv% /f /x /v

echo running system files scan
sfc /scannow /offbootdir=%_drv%\ /offwindir=%_sys% /OFFLOGFILE=%_drv%\log.txt

goto :eof


:replace

echo SxS file: %~1
echo %~1 | find /i "amd64" >nul
if NOT errorlevel 1 Set _loc=System32
echo %~1 | find /i "wow64" >nul
if NOT errorlevel 1 Set _loc=SysWOW64
echo To: %_sys%\%_loc%
echo SxS size: %~z1 Timestamp: %~t1
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
)

echo.
goto :eof
