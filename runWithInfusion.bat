@echo off
echo ------ AUTO MOOSE STARTED ------

set ROOT=%CD%

set BUILD_PATH=%WORKSPACE%
set PHARO_VM="%ROOT%\pharo\PharoVM-Win32-4\Pharo.exe"

SRC_PATH="%ROOT%\src"

SCRIPTS_PATH="%ROOT%\scripts"

echo %BUILD_PATH%
echo %ROOT%
echo %PHARO_VM%