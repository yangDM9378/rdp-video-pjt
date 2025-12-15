@echo off
echo ===============================
echo WinSCP / SFTP basic test
echo ===============================

set WINSCP=C:\rdp-video-pjt\rdp_monitor\winscp\WinSCP.com
set HOST=localhost
set USER=User
set PASS=PASSWORd

echo.
echo [1] Check WinSCP executable
if not exist "%WINSCP%" (
    echo [FAIL] WinSCP.com not found
    pause
    exit /b 1
)
echo [OK] WinSCP.com exists

echo.
echo [2] Test SFTP login
"%WINSCP%" ^
  /command ^
  "open sftp://%USER%@%HOST% -password=%PASS%" ^
  "exit"

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
