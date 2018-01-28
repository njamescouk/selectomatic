SELECT name, sql FROM sqlite_master WHERE type='table' ;
PRAGMA TABLE_INFO(rows);
PRAGMA TABLE_INFO(numbers);
SELECT name, sql FROM sqlite_master WHERE type='index' 
SELECT rowid, *  FROM rows ORDER BY rowid; 
