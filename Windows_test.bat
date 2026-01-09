@echo off
>nul 2>&1 fsutil dirty query %systemdrive% && (goto gotAdmin) || (goto Elevate_privileges)
:Elevate_privileges
:: Determine if Windows Terminal is installed.
set Terminal=cmd.exe
Powershell "Get-AppxPackage|Where Name -like '*Terminal*'"|findstr /i "Microsoft.WindowsTerminal" >nul
if "%errorlevel%"=="0" set Terminal=wt.exe
:: If gsudo is installed, use it.
if exist "C:\Program Files (x86)\gsudo\Current\gsudo.exe" sudo "%~s0" & exit /B
if exist "C:\Program Files\gsudo\Current\gsudo.exe" sudo "%~s0" & exit /B
:: If Windows Terminal is installed, use it.
powershell -Command "Start-Process %Terminal% -ArgumentList 'cmd','/c','\"%~s0\"' -Verb RunAs"
exit /b
:gotAdmin
pushd "%CD%" && CD /D "%~dp0"
cls
:: BatchGotAdmin (Run as Admin code ends)
:: Your codes should start from the following line
::===============================================================================
cd /d "%~dp0"
set Status=Startup
setlocal enabledelayedexpansion
title Twitch Channel Points Miner v2
call :ConnectionCheck https://www.twitch.tv/
set Startup="%AppData%\Microsoft\Windows\Start Menu\Programs\Startup"
if exist ScriptUpdate.bat del ScriptUpdate.bat
if not exist Auto.bat echo set Auto=False>Auto.bat
Powershell wget -Uri "https://raw.githubusercontent.com/chocolatey/choco/master/src/chocolatey.resources/redirects/RefreshEnv.cmd" -OutFile "RefreshEnv.cmd"
Powershell "if ((Get-ExecutionPolicy -List | Where-Object {$_.Scope -eq \"LocalMachine\"}).ExecutionPolicy -ne \"RemoteSigned\") { Set-ExecutionPolicy -ExecutionPolicy RemoteSigned }"
Powershell "Get-AppxPackage|Select Name"|findstr /i AppInstaller >nul
if "%errorlevel%"=="0" (
		winget upgrade Microsoft.AppInstaller --silent --accept-source-agreements --accept-package-agreements
	) else (
		start "" /wait Powershell -command "irm https://github.com/asheroto/winget-install/releases/latest/download/winget-install.ps1 | iex"
	)
Powershell -command "irm https://raw.githubusercontent.com/Neo1102/Twitch-Channel-Points-Miner-Auto-Deploy/refs/heads/main/winget_optimize.ps1 | iex"
winget list --accept-source-agreements > List.txt
findstr /i "Python.PythonInstallManager " List.txt >nul
if "%errorlevel%"=="0" ( set Action=upgrade ) else ( set Action=install )
winget %Action% Python.PythonInstallManager --silent --accept-source-agreements --accept-package-agreements

findstr /i "Git.Git " List.txt >nul
if "%errorlevel%"=="0" ( set Action=upgrade ) else ( set Action=install )
winget %Action% Git.Git --silent --accept-source-agreements --accept-package-agreements
   
findstr /i "gsudo" List.txt >nul
if "%errorlevel%"=="0" ( set Action=upgrade ) else ( set Action=install )
winget %Action% gerardog.gsudo --silent --accept-source-agreements --accept-package-agreements
sudo config --enable normal

findstr /i "Microsoft.WindowsTerminal" List.txt >nul
if "%errorlevel%"=="0" ( set Action=upgrade ) else ( set Action=install )
winget %Action% Microsoft.WindowsTerminal --silent --accept-source-agreements --accept-package-agreements
REG ADD "HKCU\Console\%%Startup" /V DelegationConsole /T REG_SZ /D "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" /F
REG ADD "HKCU\Console\%%Startup" /V DelegationTerminal /T REG_SZ /D "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" /F

findstr /i /C:"Notepad++ (64-bit x64)" List.txt >nul
if "%errorlevel%"=="0" ( set Action=upgrade ) else ( set Action=install )
winget %Action% Notepad++.Notepad++ --silent --accept-source-agreements --accept-package-agreements

del /q List.txt
set Status=Check
call RefreshEnv.cmd
cls
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
goto Menu

:Python
echo Checking Lasts Python Version ......
echo.
set LastsPythonVer=&set PythonURL=&set PyUpdate=
call :ConnectionCheck https://www.python.org/downloads/
for /f %%i in ('Powershell "(py list --online -1 -f=json | ConvertFrom-Json).versions[0].'sort-version'"') do set LastsPythonVer=%%i
py list|findstr /i /C:"No runtimes. " >nul
if "%errorlevel%"=="0" goto DownloadPython
for /f %%i in ('Powershell "(py list -f=json | ConvertFrom-Json).versions[0].'sort-version'"') do set PythonVer=%%i
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
echo  Do you want to uninstall the old version of Python?
echo  (1) No, keep old version.
echo  (2) Yes, uninstall but keeps config files. Reinstall reuses settings.
echo  (3) Yes, uninstall python and config files for full cleanup.
choice /c 123
if "%errorlevel%"=="3" py uninstall -y -purge
if "%errorlevel%"=="2" py uninstall -y
:DownloadPython
py install %LastsPythonVer% -y
py install --configure
call RefreshEnv.cmd
for /f %%i in ('Powershell "(py list -f=json | ConvertFrom-Json).versions[0].'sort-version'"') do set PythonVer=%%i
call :Requirements
set PyUpdate=
if not "%Status%"=="Check" pause
goto :eof


:Miner
echo Checking Lasts Miner Version ......
echo.
call :ConnectionCheck https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2/
set MinerVer=none&set LastsMinerVer=&set MinerUpdate=
if not exist .\TwitchChannelPointsMiner\__init__.py goto DownloadMiner
for /f "tokens=2" %%i in ('git ls-remote --tags https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2.git') do set LastsMinerVer=%%i
set LastsMinerVer=%LastsMinerVer:refs/tags/=%
for /f tokens^=2^ delims^=^" %%i in ('findstr /i "version" .\TwitchChannelPointsMiner\__init__.py') do set MinerVer=%%i
if "%MinerVer%"=="%LastsMinerVer%" (
  if "%Status%"=="Check" goto :eof
  echo No Update Available
  set Msg=Do you still want to re-download the Miner Program no matter what?
  )
if not "%MinerVer%"=="%LastsMinerVer%" (
  if "%Status%"=="Check" set MinerUpdate=[Update Available]&goto :eof
  echo Update Available
  echo Current  Version : %MinerVer%
  echo Lasts Version : %LastsMinerVer%
  set Msg=Do you want to update Miner program?
  )
echo.
choice /M:"%Msg%"
if "%errorlevel%"=="2" goto :eof
:DownloadMiner
echo Downloading Lasts Miner Program ......
git clone https://github.com/rdavydov/Twitch-Channel-Points-Miner-v2.git
echo Moving Master Program ......
echo.
robocopy ".\Twitch-Channel-Points-Miner-v2\" "%~dp0" /E /MOV /W:1
rmdir /q /s Twitch-Channel-Points-Miner-v2
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
Powershell wget -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile "get-pip.py"
py get-pip.py
py -m pip install --upgrade pip
py -m pip install setuptools
py -m pip install -r requirements.txt
py setup.py build
py setup.py install
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
powershell -command "(Invoke-WebRequest -Uri '%1' -TimeoutSec 5 -UseBasicParsing -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36').StatusCode"|findstr "200" >nul
if "%errorlevel%"=="0" goto :eof
if "%Status%"=="Startup" goto ConnectionCheck
if "%Status%"=="Check" goto :eof
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
