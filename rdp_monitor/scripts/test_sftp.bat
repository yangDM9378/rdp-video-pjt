@echo off
echo ===============================
echo OpenSSH SFTP basic test (KEY)
echo ===============================

set SFTP=C:\Windows\System32\OpenSSH\sftp.exe
set HOST=ip
set USER=username
set KEY=key path

echo.
echo [1] Check sftp executable
if not exist "%SFTP%" (
    echo [FAIL] sftp.exe not found
    pause
    exit /b 1
)
echo [OK] sftp.exe exists

echo.
echo [2] Test SFTP login (key-based)
"%SFTP%" -i "%KEY%" "%USER%@%HOST%"

if errorlevel 1 (
    echo [FAIL] SFTP connection failed
) else (
    echo [OK] SFTP connection success
)

echo.
echo ===============================
echo Test finished
echo ===============================
pause
