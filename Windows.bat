@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' EQU '0' goto gotAdmin
echo Requesting administrative privileges...
:UACPrompt
sudo /?|findstr /i "gsudo" >nul
if "%errorlevel%"=="0" sudo.exe "%~s0" & exit /B
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
exit /B
:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
:: BatchGotAdmin (Run as Admin code ends)
:: Your codes should start from the following line
::===============================================================================
cd /d "%~dp0"
choco -v >nul
if not "%errorlevel%"=="0" (
  Powershell -EncodedCommand UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAEIAeQBwAGEAcwBzACAALQBTAGMAbwBwAGUAIABQAHIAbwBjAGUAcwBzACAALQBGAG8AcgBjAGUADQAKAFsAUwB5AHMAdABlAG0ALgBOAGUAdAAuAFMAZQByAHYAaQBjAGUAUABvAGkAbgB0AE0AYQBuAGEAZwBlAHIAXQA6ADoAUwBlAGMAdQByAGkAdAB5AFAAcgBvAHQAbwBjAG8AbAAgAD0AIABbAFMAeQBzAHQAZQBtAC4ATgBlAHQALgBTAGUAcgB2AGkAYwBlAFAAbwBpAG4AdABNAGEAbgBhAGcAZQByAF0AOgA6AFMAZQBjAHUAcgBpAHQAeQBQAHIAbwB0AG8AYwBvAGwAIAAtAGIAbwByACAAMwAwADcAMgANAAoAaQBlAHgAIAAoACgATgBlAHcALQBPAGIAagBlAGMAdAAgAFMAeQBzAHQAZQBtAC4ATgBlAHQALgBXAGUAYgBDAGwAaQBlAG4AdAApAC4ARABvAHcAbgBsAG8AYQBkAFMAdAByAGkAbgBnACgAJwBoAHQAdABwAHMAOgAvAC8AYwBvAG0AbQB1AG4AaQB0AHkALgBjAGgAbwBjAG8AbABhAHQAZQB5AC4AbwByAGcALwBpAG4AcwB0AGEAbABsAC4AcABzADEAJwApACkA
  call C:\ProgramData\chocolatey\bin\RefreshEnv.cmd
)
choco outdated --limit-output|findstr /i chocolatey >nul
if "%errorlevel%"=="0" choco update chocolatey -y
choco outdated --limit-output|findstr /i sudo >nul
if "%errorlevel%"=="0" choco upgrade sudo -y
call C:\ProgramData\chocolatey\bin\RefreshEnv.cmd
set Status=Startup
setlocal enabledelayedexpansion
set Startup="%AppData%\Microsoft\Windows\Start Menu\Programs\Startup"
title Twitch Channel Points Miner v2
call :ConnectionCheck https://www.twitch.tv/
Powershell "if ((Get-ExecutionPolicy -List | Where-Object {$_.Scope -eq \"LocalMachine\"}).ExecutionPolicy -ne \"RemoteSigned\") { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned }"
if not exist Auto.bat echo set Auto=False>Auto.bat
if exist ScriptUpdate.bat del ScriptUpdate.bat
set Status=Check
call :Check_Script_Update
call :Python
call :Miner

:Menu
cd /d "%~dp0"
call Auto.bat
set Status=Menu
cls
echo  ==========================================
echo  =     Twitch Channel Points Miner v2     =
echo  ==========================================
echo    Python Version : %PythonVer% %PyUpdate%
echo    Miner  Version : %MinerVer% %MinerUpdate%
echo    Auto Start Mining : %Auto%
if "%Auto%"=="True" echo.
if "%Auto%"=="True" echo    Auto-mining has been enabled.
if "%Auto%"=="True" echo    Miner will autorun in 5s
echo.
echo    (1) Download Python
echo    (2) Download Miner Program
echo    (3) Install Requirements
echo    (4) Edit Miner Setting
if "%Auto%"=="True" echo    (5) Disable Auto Mining
if "%Auto%"=="False" echo    (5) Enable Auto Mining
if not exist %Startup%\Miner.bat echo    (6) Add to Startup
if exist %Startup%\Miner.bat echo    (6) Del from Startup
echo    (0) Start Miner
echo  ==========================================
if "%Auto%"=="True" (choice /c 1234560 /T 5 /D 0) else (choice /c 1234560)
if "%errorlevel%"=="7" call :Run
if "%errorlevel%"=="6" call :Startup
if "%errorlevel%"=="5" call :Auto
if "%errorlevel%"=="4" call :Edit
if "%errorlevel%"=="3" call :Requirements
if "%errorlevel%"=="2" call :Miner
if "%errorlevel%"=="1" call :Python
goto menu

:Python
echo Checking Lasts Python Version ......
echo.
set LastsPythonVer=&set PythonUpdate=
python --version >nul
if not "%errorlevel%"=="0" goto DownloadPython
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
for /f "delims=^| tokens=1,2,3" %%i in ('choco outdated --limit-output^|findstr /i python') do set LastsPythonVer=%%k
if "%PythonVer%"=="%LastsPythonVer%" (
    if "%Status%"=="Check" goto :eof
	echo No Update Available
	timeout 3
    goto :eof
	) else ( 
	if "%Status%"=="Check" set PyUpdate=[Update Available]&goto :eof
	)
echo Update Available
echo Current Version : %PythonVer%
echo Lasts Version : %LastsPythonVer%
choice /M:"Do you want to update Python?"
if "%errorlevel%"=="2" set PyUpdate=[Update Available]&goto :eof
:DownloadPython
choco upgrade python -y
call C:\ProgramData\chocolatey\bin\RefreshEnv.cmd
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
call :Requirements
pause
set PyUpdate=
goto :eof


:Miner
echo Checking Lasts Miner Version ......
echo.
set MinerVer=none&set GitHubVer=&set MinerUpdate=
if not exist .\TwitchChannelPointsMiner\__init__.py if "%Status%"=="Check" (set MinerUpdate=[Update Available]&goto :eof) else (goto DownloadMiner)
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
call :ConnectionCheck https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/
for /f "tokens=3" %%i in ('Powershell "Invoke-RestMethod -Uri https://api.github.com/repos/rdavydov/Twitch-Channel-Points-Miner-v2/releases/latest|Select tag_name|Format-List"') do set GitHubVer=%%i
if "%MinerVer%"=="%GitHubVer%" (
    if "%Status%"=="Check" goto :eof
	echo No Update Available
	timeout 3
    goto :eof
	) else ( 
	if "%Status%"=="Check" set MinerUpdate=[Update Available]&goto :eof
	)
echo Update Available
echo Current  Version : %MinerVer%
echo Lasts Version : %GitHubVer%
echo.
choice /M:"Do you want to update Miner program?"
if "%errorlevel%"=="2" set MinerUpdate=[Update Available]&goto :eof
:DownloadMiner
echo Downloading Lasts Miner Program ......
cd /d "%Temp%"
Powershell wget -Uri "https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/archive/refs/heads/master.zip" -OutFile "master.zip"
echo Decompression Master Program ......
echo.
tar -xf master.zip
echo Moving Master Program ......
echo.
xcopy /e /y .\Twitch-Channel-Points-Miner-v2-master "%~dp0"
echo Cleaning File ......
echo.
del /q /s master.zip Twitch-Channel-Points-Miner-v2-master
rmdir /q /s Twitch-Channel-Points-Miner-v2-master
cd /d "%~dp0"
call :Requirements
if not "%MinerVer%"=="%GitHubVer%" (
       echo.
       echo There may be differences between the new and old versions.
	   echo Please manually check if run.py matches the format of the new example.py.
	   echo Make necessary modifications manually if needed.
	   echo.
	   pause
	   )
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
set MinerUpdate=
goto :eof

:Requirements
echo Installing Requirements ......
echo.
python -m pip install --upgrade pip
python -m pip install setuptools
pip install -r requirements.txt
python setup.py build
python setup.py install
goto :eof


:Edit
if not exist run.py copy example.py run.py
set Editor=notepad
if exist "C:\Program Files (x86)\Notepad++\notepad++.exe" set Editor="C:\Program Files (x86)\Notepad++\notepad++.exe"
if exist "C:\Program Files\Notepad++\notepad++.exe" set Editor="C:\Program Files\Notepad++\notepad++.exe"
start "" %Editor% run.py
goto :eof


:Auto
if "%Auto%"=="True" echo set Auto=False>Auto.bat&goto :eof
if "%Auto%"=="False" echo set Auto=True>Auto.bat&goto :eof


:Startup
if not exist %Startup%\Miner.bat echo start "" /D "%~dp0" %~nx0>%Startup%\Miner.bat&goto :eof
if exist %Startup%\Miner.bat del %Startup%\Miner.bat&goto :eof


:Run
if not exist run.py (
      echo run.py does not exist.
	  echo Please create your config file or rename the config file to run.py
	  pause
	  goto :eof
	  )
call :ConnectionCheck https://www.twitch.tv/
python run.py
if not "%errorlevel%"=="0" timeout 10
rmdir /s /q __pycache__
rmdir /s /q TwitchChannelPointsMiner\__pycache__
rmdir /s /q TwitchChannelPointsMiner\classes\__pycache__
rmdir /s /q TwitchChannelPointsMiner\classes\entities\__pycache__
goto :eof

:ConnectionCheck
Powershell wget -Uri "%1"^|Select StatusCode|findstr "200" >nul
if "%errorlevel%"=="0" goto :eof
if "%Status%"=="Startup" goto ConnectionCheck
if "%Status%"=="Check" goto menu
echo Currently unable to connect to %1.
echo Please check your internet connection or try again later.
timeout 5
goto menu


:Check_Script_Update
echo Checking Script Update......
echo.
:Github
Powershell wget -Uri "https://raw.githubusercontent.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/main/Windows.bat" -OutFile "GitHub.bat"
if not exist GitHub.bat goto :eof
fc Windows.bat GitHub.bat >nul
if "%errorlevel%"=="0" del GitHub.bat&goto :eof
echo Update Available
choice /M:"Do you want to update Script?"
if "%errorlevel%"=="2" goto :eof
setlocal DisableDelayedExpansion
echo @echo off>ScriptUpdate.bat
echo move /y GitHub.bat Windows.bat>>ScriptUpdate.bat
echo start "" /D "%~dp0" %~nx0>>ScriptUpdate.bat
echo exit>>ScriptUpdate.bat
start ScriptUpdate.bat
exit
