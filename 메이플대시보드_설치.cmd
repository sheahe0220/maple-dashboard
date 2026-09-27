@echo off
rem force the Korean ANSI code page: this file is CP949 and a UTF-8 console (65001) misreads its Korean
rem file names and echo lines (seen 2026-09-28 on the lab PC)
chcp 949 > nul
rem One-file installer for a friend (2026-09-28). Downloads the newest dashboard build from
rem github.com/sheahe0220/maple-dashboard, checks it, unzips it to Documents\메이플대시보드 and runs 설치하기.bat.
rem Already installed -> only opens the dashboard (never overwrites the friend's key, records or settings).
rem Saved as CP949 + CRLF on purpose (Korean echo lines, batch labels).
title 메이플 대시보드 설치
set "DEST=%USERPROFILE%\Documents\메이플대시보드"
if defined MAPLE_DEST set "DEST=%MAPLE_DEST%"
echo.
echo  ==============================================
echo    메이플 대시보드 설치
echo    끝날 때까지 이 창을 닫지 마세요
echo  ==============================================
echo.

if exist "%DEST%\story\.env" goto installed

echo [1/2] 최신 판을 내려받는 중입니다 (1분 정도)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; $b='https://raw.githubusercontent.com/sheahe0220/maple-dashboard/main'; $m=Invoke-RestMethod ($b+'/latest.json'); $z=Join-Path $env:TEMP $m.zip; Invoke-WebRequest ($b+'/'+$m.zip) -OutFile $z -UseBasicParsing; if ((Get-FileHash $z -Algorithm SHA256).Hash -ne $m.sha256.ToUpper()) { throw 'download damaged' }; New-Item -ItemType Directory -Force $env:DEST | Out-Null; Expand-Archive -Path $z -DestinationPath $env:DEST -Force; Remove-Item $z"
if errorlevel 1 goto fail
if not exist "%DEST%\story\설치하기.bat" goto fail
echo      받았습니다: %DEST%\story
if "%MAPLE_NO_SETUP%"=="1" exit /b 0

echo [2/2] 설치를 시작합니다...
call "%DEST%\story\설치하기.bat"
exit /b 0

:installed
echo  이미 설치되어 있습니다. 대시보드를 엽니다.
echo  (새 판은 대시보드를 켤 때 자동으로 받으니 이 파일은 다시 쓰지 않아도 됩니다)
if "%MAPLE_NO_SETUP%"=="1" exit /b 0
start "" "%DEST%\story\.venv\Scripts\pythonw.exe" "%DEST%\story\launch_dashboard.pyw"
timeout /t 5 > nul
exit /b 0

:fail
echo.
echo  [오류] 내려받기에 실패했습니다. 인터넷 연결을 확인하고 이 파일을 다시 더블클릭해 주세요.
echo  계속 안 되면 이 창을 캡처해서 보내 주세요.
pause
exit /b 1
