-- selectomatic.sql
-- has to be invoked with sqlite3

-- get db name
.mode csv
.header on
.output selectoDbFile.csv
PRAGMA database_list;
.output
.header off
.mode list

.system echo ===================selectoDbFile.csv========================================
.system type selectoDbFile.csv
.system echo ========================================================================

-- .system sqliteimport selectomatic.db selectoDbFile.csv

SELECT '=================selectoDbFile=================================================';
.header on
SELECT * FROM selectoDbFile;
.header off
SELECT '=============================================================================';

CREATE TEMP TABLE tvNames
AS SELECT "name" FROM "sqlite_master"  WHERE type='table' OR type='view';
SELECT '=================temp.tvNames=================================================';
.header on
SELECT * FROM temp.tvNames;
.header off
SELECT '=============================================================================';

.output pragmaStmts.sql
SELECT 'PRAGMA table_info(' || name || ');' AS stmt FROM temp.tvNames;
.output

.mode csv
.output selectoCols.txt
.read pragmaStmts.sql
.output
.mode list

.system echo ===================selectoCols.txt========================================
.system type selectoCols.txt
.system echo ========================================================================

-- .system for /f %%t IN (selectoNames.txt) do sqlite3 -separator , -header %SELECTO_INPUT% "SELECT '%%t' AS %%t, * FROM %%t LIMIT 1;" | sed -n 1p;q 

--" | sed -n 1p;q >> selectoRows.txt

/*
for /f %%t IN (selectoNames.txt) do sqlite3 -separator , -header %SELECTO_INPUT% ^
        "SELECT '%%t' AS %%t, * FROM %%t LIMIT 1;" | sed -n 1p;q >> selectoRows.txt
.header off
.output

.output selectoPragma.sql
SELECT stmt FROM temp.pragmaStmts;
.output

*/

/*
rem rotate so we've got a table
echo "tableOrView","field"> tablesAndFields.csv
csvrewrite -pivot selectoRows.txt>> tablesAndFields.csv

-- could ATTACH selectomatic.db here?
.system sqlite3 selectomatic.db 'DROP TABLE IF EXISTS "selectoDbFile"'
.system sqliteimport selectomatic.db selectoDbFile.csv
*/


--views.sql
CREATE TEMP VIEW "inputs" AS 
SELECT tableOrView AS parent
, field
,'<input class="selectomaticInput" type="checkbox" onclick="doFieldChange()" name="' 
|| tableOrView || '" value="' || field || '"></input>' AS element
FROM "temp.tablesAndFields";

CREATE TEMP VIEW "labels" AS 
SELECT parent
,'<label>
' || element || '
' || field || '
</label>
' AS element
FROM "temp.inputs";

CREATE TEMP VIEW "fieldsets" AS 
SELECT '<fieldset style="display: inline;">
<legend>' || parent || '</legend>
' || group_concat(element, '
') || '
</fieldset><br/>' AS element
FROM "temp.labels"
GROUP BY parent;

CREATE TEMP VIEW "page" AS 
SELECT 1 AS seq,
'<h2>Selectomatic!</h2>
<h3>your user friendly interactive field selector for <code>' || 'db name here' || '</code></h3>
' || group_concat(element, '
') || '
<textarea row="6" cols="75" id="sqlText" placeholder="sql will appear here, as if by magic"></textarea>
' AS elements
FROM temp.fieldsets
UNION 
SELECT 2 AS seq
,'
<script type="text/javascript">
function doFieldChange()
{
    selectoInputs = document.getElementsByClassName("selectomaticInput");
    var fieldList = "";
    var fieldCount = 0;
    let tableSet = new Set();
    var i;
    for (i = 0; i < selectoInputs.length; i += 1) 
    {
        if (selectoInputs[i].type == "checkbox")
        {
            // console.log(selectoInputs[i]);
            if (selectoInputs[i].checked)
            {
                if (fieldCount > 0)
                {
                    fieldList += ",";
                }
                fieldCount++;
                fieldList += selectoInputs[i].name + "." + selectoInputs[i].value;
                tableSet.add(selectoInputs[i].name);
            }
        }
    }
    //console.log(fieldList);
    //console.log(tableSet);
    
    var tableArr = [...tableSet]; // Sets seemingly write only...
    var tableStr = "";
    for (i = 0; i < tableArr.length; i++) 
    {
        if (i > 0)
        {
            tableStr += ",";
        }
        tableStr += tableArr[i];
    }

    var selectStr = "";
    if (fieldList.length > 0)
    {
        selectStr = "SELECT DISTINCT " + fieldList + " FROM\n" + tableStr + ";";
    }
    //console.log(selectStr);

    thingy = document.getElementById("sqlText");
    thingy.innerHTML = selectStr;
}
</script>
' AS elements;

SELECT elements FROM temp.page ORDER BY seq;
