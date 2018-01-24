@echo off
if exist selectoNames.txt del selectoNames.txt
if exist selectoRows.txt del selectoRows.txt
sqlite3 ..\example\example.db "SELECT "name" FROM "sqlite_master"  WHERE type='table' OR type='view';" > selectoNames.txt
for /f %%t IN (selectoNames.txt) do sqlite3 -separator , -header ..\example\example.db "SELECT '%%t' AS %%t, * FROM %%t LIMIT 1;" | sed -n 1p;q >> selectoRows.txt

echo "tableOrView","field"> tablesAndFields.csv
csvrewrite -pivot selectoRows.txt>> tablesAndFields.csv

if exist selectomatic.db del selectomatic.db
sqliteimport selectomatic.db tablesAndFields.csv
sqlite3 selectomatic.db < views.sql

