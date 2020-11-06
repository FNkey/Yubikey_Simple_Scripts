@echo off

set "pivtool="
set "answer="

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
echo.
echo WARNING!
echo Next step will reset Yubikey!
echo Are you sure want to continue? (Y/[N], Default - N)
set /p answer=%

if /I "%answer%" NEQ "Y" (
						echo Exiting.
						EXIT /b 1
) else (
		echo.
		echo Starting reset procedure...
		)

for /l %%x in (10, -1, 1) do (
   echo Blocking Yubikey PIN. Remaining time is around %%x seconds.
   %pivtool% -a verify-pin -P 471112 >nul 2>&1
   timeout 1 > NUL
   taskkill /im "yubico-piv-tool.exe" /f >nul 2>&1
)

for /l %%x in (10, -1, 1) do (
   echo Blocking Yubikey PUK. Remaining time is around %%x seconds.
   %pivtool% -a change-puk -P 12345678 -N 98765432 >nul 2>&1
   timeout 1 > NUL
   taskkill /im "yubico-piv-tool.exe" /f >nul 2>&1
)

echo Resetting Yubikey...
%pivtool% -a reset

pause