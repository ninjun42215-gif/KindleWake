@echo off
setlocal
cd /d "%~dp0"
echo ============================================
echo  Kindlewake - build the Android installer
echo ============================================
echo.
set "PY="
where py >nul 2>nul && set "PY=py -3"
if not defined PY (
  where python >nul 2>nul && set "PY=python"
)
if not defined PY (
  echo Python 3 is not installed.
  echo Install it from https://www.python.org/downloads/ and tick "Add python.exe to PATH",
  echo then double-click this file again.
  pause
  exit /b 1
)
%PY% tools\build_apk.py %*
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (
  echo Finished OK. Your installer is dist\Kindlewake.apk
) else (
  echo Build FAILED ^(code %RC%^). Copy the text above, or dist\logs\BUILD_SUMMARY.txt, into the chat.
)
pause
exit /b %RC%
