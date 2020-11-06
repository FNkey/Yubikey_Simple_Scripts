@echo off

setlocal enabledelayedexpansion
set "mgmtKEY="
set "pinKEY="
set "pukKEY="
set "pivtool="
set "answer="
set "certADM="
set "certINT="

set "string=abcdefABCDEF0123456789"
for /L %%i in (1,1,48) do call :randomKEY

set "string=0123456789"
for /L %%i in (1,1,8) do call :randomPIN

set "string=0123456789"
for /L %%i in (1,1,8) do call :randomPUK

echo Searching for Yubico PIV tool application...
for /r "%PROGRAMFILES%\Yubico\" %%a in (*) do if "%%~nxa"=="yubico-piv-tool.exe" set pivtool=%%~dpnxa
if defined pivtool (
	set pivtool="%pivtool%"
	echo Yubico PIV tool found.
) else (
	echo Yubico PIV tool not found.
	echo Please enter yubico-piv-tool.exe full path in quotes:
	set /p pivtool=%
	)

if exist %pivtool% (
					echo Yubico tool path: %pivtool%
) else (
	echo Wrong path. Exiting.
	EXIT /b 1
	)

echo Getting Yubikey status...
%pivtool% -a status

echo.
echo Setting Yubikey management key...
%pivtool% -a set-mgm-key -n %mgmtKEY%

echo Setting Yubikey PIN and PUK retry limits...
%pivtool% -a verify -P 123456 --key=%mgmtKEY% -a pin-retries --pin-retries 10 --puk-retries 10

echo Setting Yubikey PIN and PUK keys...
%pivtool% -a change-pin -P 123456 -N %pinKEY%
%pivtool% -a change-puk -P 12345678 -N %pukKEY%


echo Please enter full path to PIV Authentication PFX-cetificate in quotes:
set /p certINT=%
echo Please enter full path to Card Authentication PFX-cetificate in quotes:
set /p certADM=%

echo Uploading PIV Authentication PFX-cetificate to Yubikey Slot 9a...
%pivtool% -s 9a -i %certINT% -K PKCS12 -a set-chuid -a import-key -a import-cert --key=%mgmtKEY%
echo Uploading Card Authentication PFX-cetificate to Yubikey Slot 9e...
%pivtool% -s 9e -i %certADM% -K PKCS12 -a set-chuid -a import-key -a import-cert --touch-policy=cached --pin-policy=always --key=%mgmtKEY%

echo Getting Yubikey status...
%pivtool% -a status

echo Yubikey management key: %mgmtKEY%
echo Yubikey PIN code: %pinKEY%
echo Yubikey PUK code: %pukKEY%

pause

:randomKEY
set /a x=%random% %% 22 
set mgmtKEY=%mgmtKEY%!string:~%x%,1!
goto :eof

:randomPIN
set /a x=%random% %% 10 
set pinKEY=%pinKEY%!string:~%x%,1!
goto :eof

:randomPUK
set /a x=%random% %% 10 
set pukKEY=%pukKEY%!string:~%x%,1!
goto :eof
