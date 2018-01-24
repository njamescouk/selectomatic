@echo off
set COMPILE_SRCS=I:\lib\sqliteUtilLib\md5Ext\md5.c I:\lib\sqliteUtilLib\powExt\powext.c I:\lib\sqliteUtilLib\regexExt\regexp.c I:\usr\NIK\dev\JsonWriter\source\JsonValue.cpp I:\usr\NIK\dev\parseCmdline\source\lex.pcl.c I:\usr\NIK\dev\parseCmdline\source\pcl.tab.c I:\usr\NIK\dev\split_string\split_string.cpp I:\usr\NIK\dev\sqliteUtils\sqliteUtils.cpp I:\usr\NIK\dev\stringtime\stringtime.cpp ..\source\main.cpp ..\source\lex.yy.c ..\source\y.tab.c 
 
set COMPILE_INCLUDES=-II:/lib/yacc -I../source -II:\lib\sqlite\ver_3_15_2 -II:\usr\NIK\dev\JsonWriter\source -II:\usr\NIK\dev\parseCmdline\source -II:\usr\NIK\dev\split_string -II:\usr\NIK\dev\sqliteUtils -II:\usr\NIK\dev\stringtime

set COMPILE_DEFINES=-DSQLITE_CORE -DSQLITE_ENABLE_MD5

set OLDPATH=%PATH%
set PATH=c:\bin\MinGWNew\bin;%OLDPATH%
 
rem set these for your machine...
set YACCPATH="C:\Program Files (x86)\GnuWin32\bin\yacc.exe"
set SEDPATH="C:\Program Files (x86)\GnuWin32\bin\sed.exe"
set FLEXPATH="C:\Program Files (x86)\GnuWin32\bin\flex.exe"
set GPPPATH="c:\bin\MinGWNew\bin\g++.exe"
set GCCPATH="c:\bin\MinGWNew\bin\gcc.exe"
 
echo ************************************
echo         MAKING selectomatic.exe
echo ************************************
 
%YACCPATH% -ldv ../source/selectomatic.y
 
%SEDPATH% "/extern char \*getenv();/d" y.tab.c > junk
del y.tab.c
move junk y.tab.c 
 
move y.tab.c ../source 
move y.tab.h ../source 
 
%GCCPATH% -c I:\lib\sqlite\ver_3_15_2\sqlite3.c
%FLEXPATH% -o../source/lex.yy.c ../source/selectomatic.l
%GPPPATH%  -g -o selectomatic.exe %COMPILE_INCLUDES% %COMPILE_SRCS% sqlite3.o
 
:clean
set COMPILE_SRCS=
set COMPILE_INCLUDES=
set YACCPATH=
set SEDPATH=
set GPPPATH=
set PATH=%OLDPATH%
set OLDPATH=
set GCCPATH=
set COMPILE_DEFINES=
