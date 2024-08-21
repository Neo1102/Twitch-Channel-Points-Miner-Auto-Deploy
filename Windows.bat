@echo off
cls
set Terminal=cmd.exe
Powershell "Get-AppxPackage|Where Name -like '*Terminal*'"|findstr /i "Microsoft.WindowsTerminal" >nul
if "%errorlevel%"=="0" set Terminal=wt.exe
:: BatchGotAdmin (Run as Admin code starts)
REM --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
REM --> If error flag set, we do not have admin.
if '%errorlevel%' EQU '0' goto gotAdmin
echo Requesting administrative privileges...
goto UACPrompt
:UACPrompt
if exist "C:\Program Files (x86)\gsudo\Current\gsudo.exe" sudo "%~s0" & exit /B
if exist "C:\Program Files\gsudo\Current\gsudo.exe" sudo "%~s0" & exit /B
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%Terminal%", "cmd /c %~s0", "", "runas", 1 >> "%temp%\getadmin.vbs"
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
set Status=Startup
setlocal enabledelayedexpansion
title Twitch Channel Points Miner v2
call :ConnectionCheck https://www.twitch.tv/
set Startup="%AppData%\Microsoft\Windows\Start Menu\Programs\Startup"
Powershell "if ((Get-ExecutionPolicy -List | Where-Object {$_.Scope -eq \"LocalMachine\"}).ExecutionPolicy -ne \"RemoteSigned\") { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned }"
if not exist Auto.bat echo set Auto=False>Auto.bat
if exist ScriptUpdate.bat del ScriptUpdate.bat
set Status=Check
call :Check_Script_Update
call :Python
call :Miner
Powershell "Get-AppxPackage|Select Name"|findstr /i AppInstaller >nul
if not "%errorlevel%"=="0" start "" /wait Powershell -command "irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex"
winget list --accept-source-agreements > List.txt
findstr /i "gsudo" List.txt >nul
if not "%errorlevel%"=="0" winget install gerardog.gsudo --accept-source-agreements >nul
findstr /i "Microsoft.WindowsTerminal" List.txt >nul
if not "%errorlevel%"=="0" winget install Microsoft.WindowsTerminal --accept-source-agreements >nul
findstr /i /C:"Notepad++ (64-bit x64)" List.txt >nul
if not "%errorlevel%"=="0" winget install Notepad++.Notepad++ --accept-source-agreements >nul
del /q List.txt

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
goto Menu

:Python
echo Checking Lasts Python Version ......
echo.
set LastsPythonVer=&set PythonURL=&set PyUpdate=
call :ConnectionCheck https://www.python.org/downloads/
for /f "delims=" %%i in ('Powershell -EncodedCommand "JABjAG8AbgB0AGUAbgB0ACAAPQAgACgASQBuAHYAbwBrAGUALQBXAGUAYgBSAGUAcQB1AGUAcwB0ACAALQBVAHIAaQAgACIAaAB0AHQAcABzADoALwAvAHcAdwB3AC4AcAB5AHQAaABvAG4ALgBvAHIAZwAvAGQAbwB3AG4AbABvAGEAZABzAC8AIgApAC4AQwBvAG4AdABlAG4AdAANAAoAJAB1AHIAbABQAGEAdAB0AGUAcgBuACAAPQAgACcAaAByAGUAZgA9ACIAKABoAHQAdABwAHMAOgAvAC8AdwB3AHcALgBwAHkAdABoAG8AbgAuAG8AcgBnAFsAXgAiAF0AKwBcAC4AZQB4AGUAKQAiACcADQAKACQAcgBlAGcAZQB4ACAAPQAgAFsAcgBlAGcAZQB4AF0AOgA6AG4AZQB3ACgAJAB1AHIAbABQAGEAdAB0AGUAcgBuACkADQAKACQAbQBhAHQAYwBoACAAPQAgACQAcgBlAGcAZQB4AC4ATQBhAHQAYwBoACgAJABjAG8AbgB0AGUAbgB0ACkADQAKAGkAZgAgACgAJABtAGEAdABjAGgALgBTAHUAYwBjAGUAcwBzACkAIAB7AA0ACgAgACAAIAAgACQAZABvAHcAbgBsAG8AYQBkAFUAcgBsACAAPQAgACQAbQBhAHQAYwBoAC4ARwByAG8AdQBwAHMAWwAxAF0ALgBWAGEAbAB1AGUADQAKAAkAVwByAGkAdABlAC0ASABvAHMAdAAgACQAZABvAHcAbgBsAG8AYQBkAFUAcgBsAA0ACgB9AA=="') do set PythonURL=%%i
for /f "delims=/ tokens=5" %%i in ('echo %PythonURL%') do set LastsPythonVer=%%i
python --version >nul
if not "%errorlevel%"=="0" goto DownloadPython
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
if "%PythonVer%"=="%LastsPythonVer%" (
  if "%Status%"=="Check" goto :eof
  echo No Update Available
  timeout 3
  goto :eof
  )
set PyUpdate=[Update Available]
if "%Status%"=="Check" goto :eof
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
Powershell wget -Uri "https://raw.githubusercontent.com/chocolatey/choco/master/src/chocolatey.resources/redirects/RefreshEnv.cmd" -OutFile "RefreshEnv.cmd"
call RefreshEnv.cmd
for /f "tokens=2" %%i in ('python --version^|findstr /i "Python"') do set PythonVer=%%i
call :Requirements
set PyUpdate=
if not "%Status%"=="Check" pause
goto :eof


:Miner
echo Checking Lasts Miner Version ......
echo.
set MinerVer=none&set GitHubVer=&set MinerUpdate=
if not exist .\TwitchChannelPointsMiner\__init__.py goto DownloadMiner
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
call :ConnectionCheck https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/
for /f tokens^=2^ delims^=^" %%i in ('Powershell wget -Uri "https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/raw/master/TwitchChannelPointsMiner/__init__.py"^|findstr /i __version__') do set GitHubVer=%%i
if "%MinerVer%"=="%GitHubVer%" (
  if "%Status%"=="Check" goto :eof
  echo No Update Available
  set Msg=Do you want to download the main program again?
  )
if not "%MinerVer%"=="%GitHubVer%" (
  if "%Status%"=="Check" set MinerUpdate=[Update Available]&goto :eof
  echo Update Available
  echo Current  Version : %MinerVer%
  echo Lasts Version : %GitHubVer%
  set Msg=Do you want to update Miner program?
  )
echo.
choice /M:"%Msg%"
if "%errorlevel%"=="2" goto :eof
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
if exist getPython.ps1 del getPython.ps1
call :Requirements
echo.
echo                         --- Complete ---
echo There may be differences between the new and old versions.
echo Please manually check if run.py matches the format of the new example.py.
echo Make necessary modifications manually if needed.
echo.
if not "%Status%"=="Check" pause
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
set MinerUpdate=
goto :eof

:Requirements
if not exist .\requirements.txt goto :eof
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
