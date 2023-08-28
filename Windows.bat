@echo off
cls
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
echo Requesting Administrative Privileges...
goto UACPrompt
) else ( goto gotAdmin )
:UACPrompt
if not exist sudo.exe Powershell wget -Uri "https://raw.githubusercontent.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/main/sudo.exe" -OutFile "sudo.exe"
sudo.exe "%~s0"
exit /B
:gotAdmin
::===============================================================================
cd /d "%~dp0"
setlocal enabledelayedexpansion
title Twitch Channel Points Miner v2
set Startup="%AppData%\Microsoft\Windows\Start Menu\Programs\Startup"
Powershell "if ((Get-ExecutionPolicy -List | Where-Object {$_.Scope -eq \"LocalMachine\"}).ExecutionPolicy -ne \"RemoteSigned\") { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned }"
if not exist Auto.bat echo set Auto=False>Auto.bat
if exist ScriptUpdate.bat del ScriptUpdate.bat
if not exist getPython.ps1  Powershell wget -Uri "https://raw.githubusercontent.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/main/getPython.ps1" -OutFile "getPython.ps1"
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
set PythonVer=none&set LastsPythonVer=&set PythonURL=&set PythonUpdate=
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
call :CheckConnection https://www.python.org/downloads/
for /f "delims=" %%i in ('Powershell -File getPython.ps1') do set PythonURL=%%i
for /f "delims=/ tokens=5" %%i in ('echo %PythonURL%') do set LastsPythonVer=%%i
if "%PythonVer%"=="%LastsPythonVer%" (
    if "%Status%"=="Check" goto :eof
	echo No Update Available
	timeout 3
    goto :eof
	) else ( 
	if "%Status%"=="Check" set PythonUpdate=Update Available&goto :eof
	)
if "%PythonVer%"=="none" goto DownloadPython
echo Update Available
echo Current Version : %PythonVer%
echo Lasts Version : %LastsPythonVer%
choice /M:"Do you want to update Python?"
if "%errorlevel%"=="2" goto :eof
:DownloadPython
echo Downloading Python %LastsPythonVer% Installer ......
echo.
cd /d "%Temp%"
Powershell wget -Uri "%PythonURL%" -OutFile "python.exe"
echo Installing Python %LastsPythonVer% ......
if exist python.exe python.exe /passive InstallAllUsers=1 AppendPath=1 PrependPath=1
echo Cleaning File ......
echo.
del /q python.exe
cd /d "%~dp0"
if not exist RefreshEnv.cmd Powershell wget -Uri "https://raw.githubusercontent.com/chocolatey/choco/master/src/chocolatey.resources/redirects/RefreshEnv.cmd" -OutFile "RefreshEnv.cmd"
call RefreshEnv.cmd
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
goto :eof


:Miner
echo Checking Lasts Miner Version ......
echo.
set MinerVer=none&set GitHubVer=&set MinerUpdate=
if not exist .\TwitchChannelPointsMiner\__init__.py if "%Status%"=="Check" (set MinerUpdate=Update Available&goto :eof) else (goto DownloadMiner)
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
call :CheckConnection https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/
for /f tokens^=2^ delims^=^" %%i in ('Powershell "wget -Uri "https://raw.githubusercontent.com/rdavydov/Twitch-Channel-Points-Miner-v2/master/TwitchChannelPointsMiner/__init__.py"|Select Content|Format-List"^|findstr /OFF /i "version"') do set GitHubVer=%%i
if "%MinerVer%"=="%GitHubVer%" (
    if "%Status%"=="Check" goto :eof
	echo No Update Available
	timeout 3
    goto :eof
	) else ( 
	if "%Status%"=="Check" set MinerUpdate=Update Available&goto :eof
	)
echo Update Available
echo Current  Version : %MinerVer%
echo Lasts Version : %GitHubVer%
echo.
choice /M:"Do you want to update Miner program?"
if "%errorlevel%"=="2" goto :eof
:DownloadMiner
echo Downloading Lasts Miner Program......
cd /d "%Temp%"
Powershell wget -Uri "https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/archive/refs/heads/master.zip" -OutFile "master.zip"
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
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
:Requirements
echo Installing Requirements ......
echo.
pip install -r requirements.txt
python setup.py build
python setup.py install
if not "%MinerVer%"=="%GitHubVer%" (
       echo.
       echo There may be differences between the new and old versions.
	   echo Please manually check if run.py matches the format of the new example.py.
	   echo Make necessary modifications manually if needed.
	   echo.
	   )
pause
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
call :CheckConnection https://www.twitch.tv/
python run.py
if not "%errorlevel%"=="0" timeout 10
rmdir /s /q __pycache__
rmdir /s /q TwitchChannelPointsMiner\__pycache__
rmdir /s /q TwitchChannelPointsMiner\classes\__pycache__
rmdir /s /q TwitchChannelPointsMiner\classes\entities\__pycache__
goto :eof

:CheckConnection
Powershell wget -Uri "%1"^|Select StatusCode|findstr "200" >nul
if "%errorlevel%"=="0" goto :eof
if "%Status%"=="Check" goto menu
echo Currently unable to connect to %1.
echo Please check your internet connection or try again later.
timeout 5
goto menu


:Check_Script_Update
echo Checking Script Update......
echo.
Powershell wget -Uri "https://raw.githubusercontent.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/main/Windows.bat" -OutFile "GitHub.bat"
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
