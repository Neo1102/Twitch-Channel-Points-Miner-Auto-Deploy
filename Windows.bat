@echo off
:: BatchGotAdmin (Run as Admin code starts)
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
echo Requesting administrative privileges...
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
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
setlocal enabledelayedexpansion
title Twitch Channel Points Miner v2
set Startup="%AppData%\Microsoft\Windows\Start Menu\Programs\Startup"
Powershell "if ((Get-ExecutionPolicy -List | Where-Object {$_.Scope -eq \"LocalMachine\"}).ExecutionPolicy -ne \"RemoteSigned\") { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned }"
if not exist Auto.bat echo set Auto=False>Auto.bat
:Menu
call Auto.bat
cd /d "%~dp0"
set PythonVer=none
set LocalVer=none
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set LocalVer=%%i
cls
echo  ==========================================
echo  =     Twitch Channel Points Miner v2     =
echo  ==========================================
echo    Python Version : %PythonVer%
echo    Miner  Version : %LocalVer%
echo    Auto Start Mining : %Auto%
if "%Auto%"=="True" echo.
if "%Auto%"=="True" echo    run.py are exist
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
if "%errorlevel%"=="7" goto Run
if "%errorlevel%"=="6" goto Startup
if "%errorlevel%"=="5" goto Auto
if "%errorlevel%"=="4" goto Edit
if "%errorlevel%"=="3" goto Requirements
if "%errorlevel%"=="2" goto Miner
if "%errorlevel%"=="1" goto Python


:Python
if "%PythonVer%"=="none" goto DownloadPython
echo Checking Lasts Python Version ......
echo.
set LocalPython=&set PythonURL=
if not exist getPython.ps1 wget -q --show-progress --no-hsts https://raw.githubusercontent.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/main/getPython.ps1
for /f "delims=" %%i in ('Powershell -File getPython.ps1') do set PythonURL=%%i
for /f "delims=/ tokens=5" %%i in ('echo %PythonURL%') do set LastsPythonVer=%%i
if "%PythonVer%"=="%LastsPythonVer%" (
    echo no Update Available
	timeout 3
    goto menu
	)
echo Update Available!
echo Current Version : %PythonVer%
echo Lasts Version : %LastsPythonVer%
choice /M:"Do you want to update Python?"
if "%errorlevel%"=="2" goto menu
:DownloadPython
echo Downloading Python Installer ......
echo.
cd /d "%Temp%"
"%~dp0wget" -q --show-progress --no-hsts %PythonURL%
for /f "delims=" %%i in ('dir /b *.exe ^|findstr /i "python"') do set pyinst=%%i
echo Installing %pyinst% ......
if exist %pyinst% %pyinst% /passive InstallAllUsers=1 AppendPath=1 PrependPath=1
echo Cleaning File ......
echo.
del /q %pyinst%
if not exist RefreshEnv.cmd "%~dp0wget" -q --show-progress --no-hsts https://raw.githubusercontent.com/chocolatey/choco/master/src/chocolatey.resources/redirects/RefreshEnv.cmd
call RefreshEnv.cmd
goto menu


:Miner
if not exist .\TwitchChannelPointsMiner\__init__.py goto DownloadMiner
echo Checking Lasts Miner Version ......
echo.
set LocalVer=&set GitHubVer=
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set LocalVer=%%i
for /f tokens^=2^ delims^=^" %%i in ('Powershell Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rdavydov/Twitch-Channel-Points-Miner-v2/master/TwitchChannelPointsMiner/__init__.py"^|findstr /i "version"') do set GitHubVer=%%i
if "%LocalVer%"=="%GitHubVer%" (
    echo no Update Available
	timeout 3
    goto menu
	)
echo Update Available!
echo Current  Version : %LocalVer%
echo Lasts Version : %GitHubVer%
echo.
choice /M:"Do you want to update Miner Program?"
if "%errorlevel%"=="2" goto menu
:DownloadMiner
echo Downloading Lasts Miner Program......
cd /d "%Temp%"
"%~dp0wget" -q --show-progress --no-hsts https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/archive/refs/heads/master.zip
echo Decompression Master Program ......
echo.
tar -xf master.zip
echo Move Master Program ......
echo.
xcopy /e /y .\Twitch-Channel-Points-Miner-v2-master "%~dp0"
echo Cleaning File ......
echo.
del /q /s master.zip Twitch-Channel-Points-Miner-v2-master
rmdir /q /s Twitch-Channel-Points-Miner-v2-master
cd /d "%~dp0"
:Requirements
echo Installing Requirements ......
echo.
pip install -r requirements.txt
python setup.py build
python setup.py install
if not "%LocalVer%"=="%GitHubVer%" (
       echo.
       echo There may be differences between the new and old versions.
	   echo Please manually check if run.py matches the format of the new example.py.
	   echo Make necessary modifications manually if needed.
	   echo.
	   )
pause
goto Menu


:Edit
if not exist run.py copy example.py run.py
set Editor=notepad
if exist "C:\Program Files (x86)\Notepad++\notepad++.exe" set Editor="C:\Program Files (x86)\Notepad++\notepad++.exe"
if exist "C:\Program Files\Notepad++\notepad++.exe" set Editor="C:\Program Files\Notepad++\notepad++.exe"
start "" %Editor% run.py
goto Menu


:Auto
if "%Auto%"=="True" set Auto=False&goto menu
if "%Auto%"=="False" set Auto=True&goto menu


:Startup
if not exist %Startup%\Miner.bat echo start "" /D "%~dp0" %~nx0>%Startup%\Miner.bat&goto Menu
if exist %Startup%\Miner.bat del %Startup%\Miner.bat&goto Menu


:Run
if not exist run.py (
      echo run.py does not exist.
	  echo Please create your config file or rename the config file to run.py
	  pause
	  goto Menu
	  )
python run.py
if "%errorlevel%"=="1" pause
rmdir /s /q __pycache__
rmdir /s /q TwitchChannelPointsMiner\__pycache__
rmdir /s /q TwitchChannelPointsMiner\classes\__pycache__
rmdir /s /q TwitchChannelPointsMiner\classes\entities\__pycache__
goto Menu
