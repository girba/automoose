@echo off
echo ------ AUTO MOOSE STARTED ------

set ROOT=%CD%

set BUILD_PATH=%WORKSPACE%
set BUILD_PATH=%ROOT%\build
set PHARO_VM=%ROOT%\pharo\PharoVM-Win32-4\Pharo.exe

set SRC_PATH="%ROOT%\src"

set SCRIPTS_PATH="%ROOT%\scripts"

set COMPLETE_SCRIPT="$SCRIPTS_PATH/to-run.st"

set MOOSE_FILE="moose-"
set MOOSE_IMAGE_FILE="%MOOSE_FILE%.image"
set MOOSE_CHANGES_FILE="%MOOSE_FILE%.changes"

md "%BUILD_PATH%\%MOOSE_FILE%"
cd "%BUILD_PATH%\%MOOSE_FILE%"

echo FOR /F "TOKENS=1* DELIMS= " %%A IN ('TIME/T') DO SET CTIME=%%B For /f "tokens=1-4 delims=: " %%a in ('time /t') do (set time=%%a%%b%%c)

echo %BUILD_PATH%
echo %ROOT%
echo %PHARO_VM%