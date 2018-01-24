rem @echo off
if "%1"=="" echo no db given & goto usage
if "%1"=="-h" goto usage

set SELECTO_DB=selectomatic.db
set SELECTO_INPUT=%1

if exist selectoNames.txt del selectoNames.txt
if exist selectoRows.txt del selectoRows.txt

rem get table names and field names
sqlite3 %SELECTO_INPUT% "SELECT "name" FROM "sqlite_master"  WHERE type='table' OR type='view';" > selectoNames.txt
for /f %%t IN (selectoNames.txt) do sqlite3 -separator , -header %SELECTO_INPUT% ^
        "SELECT '%%t' AS %%t, * FROM %%t LIMIT 1;" | sed -n 1p;q >> selectoRows.txt

rem rotate so we've got a table
echo "tableOrView","field"> tablesAndFields.csv
csvrewrite -pivot selectoRows.txt>> tablesAndFields.csv

rem import into selecto db and add views for selecto html
if exist %SELECTO_DB% del %SELECTO_DB%
sqliteimport %SELECTO_DB% tablesAndFields.csv
sqlite3 %SELECTO_DB% < views.sql

rem bingo
sqlite3 %SELECTO_DB% "SELECT elements FROM page;" | htmlwrap > selectomatic.html

set SELECTO_DB=
set SELECTO_INPUT=

goto :eof

:usage

echo %0 dbFile
echo produces selectomatic.html which enables interactive choice
echo of fields to display from  tables in dbfile.
goto :eof