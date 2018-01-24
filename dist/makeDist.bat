@echo off
rem 
set MD_ROOT=selectomatic
set VERSION=1.0
set CURZIP=%MD_ROOT%_%VERSION%.zip

goto main

:abortVer
echo.
echo %EXE_VER% != %MD_ROOT% version %VERSION%
echo ========
echo aborting
echo ========
pause
goto tidy

:main
copy \usr\NIK\dev\split_string\split_string.* ..\source  > nul
copy \usr\NIK\dev\stringtime\stringtime.cpp ..\source  > nul
copy \usr\NIK\dev\stringtime\stringtime.h ..\source  > nul
rem copy \usr\NIK\dev\webApiGen\source\wagParam.cpp ..\source > nul
rem copy \usr\NIK\dev\webApiGen\source\wagParam.h ..\source > nul

echo ************************************
echo *******          GCC         *******
echo ************************************
pushd ..\gcc
copy C:\bin\MinGWNew\bin\libgcc_s_dw2-1.dll >nul
copy "C:\bin\MinGWNew\bin\libstdc++-6.dll" > nul

if exist %MD_ROOT%.exe del %MD_ROOT%.exe
if exist ..\%MD_ROOT%.exe del ..\%MD_ROOT%.exe
if exist c:\bin\%MD_ROOT%.exe del c:\bin\%MD_ROOT%.exe

call compile.bat
if exist %MD_ROOT%.exe copy %MD_ROOT%.exe .. > nul
if exist %MD_ROOT%.exe copy %MD_ROOT%.exe c:\bin > nul
popd

%MD_ROOT% -v > _junk.txt
set /p EXE_VER= < _junk.txt
del _junk.txt
if not "%EXE_VER%"=="%MD_ROOT% version %VERSION%" goto abortVer

echo ************************************
echo *******        EXAMPLE       *******
echo ************************************
pushd ..\example

rem call compile.bat
rem call compileApi.bat

popd

echo ************************************
echo *******         DOC          *******
echo ************************************
pushd ..\doc
call makeDoc.bat
popd

echo ************************************
echo *******         SOURCE       *******
echo ************************************
pushd ..\source

popd

echo ************************************
echo *******       ZIPPING        *******
echo ************************************
if exist %CURZIP% del %CURZIP%

pushd ..\..
if exist "C:\Program Files (x86)\UltimateZip 2007\uzcomp.exe" "C:\Program Files (x86)\UltimateZip 2007\uzcomp.exe" -P -a %MD_ROOT%\dist\%CURZIP% @%MD_ROOT%\dist\fileList.txt
if exist "C:\Program Files\UltimateZip 2007\uzcomp.exe" "C:\Program Files\UltimateZip 2007\uzcomp.exe" -P -a %MD_ROOT%\dist\%CURZIP% @%MD_ROOT%\dist\fileList.txt
popd

copy %CURZIP% %LA_CIE_DRIVE%:\usr\NIK\website\nfs\home\public\download > nul
:copyDocs
copy ..\doc\%MD_ROOT%.html %LA_CIE_DRIVE%:\usr\NIK\website\nfs\home\public\reference > nul
copy ..\doc\%MD_ROOT%.css %LA_CIE_DRIVE%:\usr\NIK\website\nfs\home\public\reference > nul


:tidy
set MD_ROOT=
set CURZIP=
set VERSION=
del ..\source\split_string.*
del ..\source\stringtime.*
del ..\gcc\*.dll
