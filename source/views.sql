--views.sql
CREATE VIEW "inputs" AS 
SELECT tableOrView AS parent
, field
,'<input type="checkbox" onclick="doFieldChange(this)" name="' || tableOrView || '" value="' || field || '"></input>' AS element
FROM "tablesAndFields";


CREATE VIEW "labels" AS 
SELECT parent
,'<label>
' || element || '
' || field || '
</label>
' AS element
FROM "inputs";

