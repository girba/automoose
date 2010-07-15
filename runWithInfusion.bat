@echo off
echo ------ AUTO MOOSE STARTED ------

set ROOT=%CD%

set PROJECT_PREFIX=system
set BUILD_PATH=%WORKSPACE%
set BUILD_PATH=%ROOT%\builds
set PHARO_VM=%ROOT%\pharo\PharoVM-Win32-4\Pharo.exe
set PHARO_VM=%ROOT%\pharo\Squeak.exe

set PHARO_PARAM=-headless
set SRC_PATH=%ROOT%\src
set SCRIPTS_PATH=%ROOT%\scripts
set COMPLETE_SCRIPT=%SCRIPTS_PATH%\to-run.st
set INFUSION=%ROOT%\inFusion

for /f "tokens=1,2" %%u in ('date /t') do set d=%%v
for /f "tokens=1" %%u in ('time /t') do set t=%%u
if "%t:~1,1%"==":" set t=0%t%
set datestr=%d:~6,4%%d:~0,2%%d:~3,2%
set timestr=%t:~0,2%%t:~3,2%
rem SET DATE=%date:~0,4%-%date:~7,2%-%date:~4,2%-%time:~0,2%-%time:~3,2%-%time:~6,2%
set DATE=%datestr%-%timestr%

echo Start inFusion
set MSE_FILE=%PROJECT_PREFIX%-%DATE%.mse

cd %INFUSION%
call java2mse.bat "%SRC_PATH%" "famix30" "%MSE_FILE%"

rem if not exist "%MSE_FILE%" 
rem	exit 1
rem fi

set MOOSE_FILE=moose-%PROJECT_PREFIX%-%DATE%
set MOOSE_IMAGE_FILE=%MOOSE_FILE%.image
set MOOSE_CHANGES_FILE=%MOOSE_FILE%.changes

md "%BUILD_PATH%\%MOOSE_FILE%"

move "%INFUSION%\%MSE_FILE%" "%BUILD_PATH%\%MOOSE_FILE%\"
rmdir "%INFUSION%\temp" /S /Q

copy "%ROOT%\res\moose.image" "%BUILD_PATH%\%MOOSE_FILE%\%MOOSE_IMAGE_FILE%"
copy "%ROOT%\res\moose.changes" "%BUILD_PATH%\%MOOSE_FILE%\%MOOSE_CHANGES_FILE%"
copy "%ROOT%\res\*.sources" "%BUILD_PATH%\%MOOSE_FILE%\"

cd %ROOT%
call robocopy "%SRC_PATH%" "%BUILD_PATH%\%MOOSE_FILE%\src" *.java /s

cd "%BUILD_PATH%\%MOOSE_FILE%\"

echo Start Moose
call "%PHARO_VM%" "%MOOSE_IMAGE_FILE%" "%COMPLETE_SCRIPT%"

cd %ROOT%
echo ------ AUTO MOOSE DONE ------