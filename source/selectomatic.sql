-- selectomatic.sql
SELECT "name", "sql"  FROM "sqlite_master"  WHERE type='table' OR type='view';

