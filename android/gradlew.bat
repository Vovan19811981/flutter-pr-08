@echo off
setlocal
set GRADLE_VERSION=8.10.2
set GRADLE_HOME_DIR=%USERPROFILE%\.gradle\manual\gradle-%GRADLE_VERSION%
set GRADLE_BIN=%GRADLE_HOME_DIR%\bin\gradle.bat

if not exist "%GRADLE_BIN%" (
  set ZIP_FILE=%TEMP%\gradle-%GRADLE_VERSION%-bin.zip
  powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing 'https://services.gradle.org/distributions/gradle-%GRADLE_VERSION%-bin.zip' -OutFile '%ZIP_FILE%'; New-Item -ItemType Directory -Force -Path '%USERPROFILE%\.gradle\manual' | Out-Null; Expand-Archive -Force '%ZIP_FILE%' '%USERPROFILE%\.gradle\manual'"
  if errorlevel 1 exit /b 1
)

call "%GRADLE_BIN%" %*
endlocal
