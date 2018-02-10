package require sqlite3
set selectoDBFile selectomatic.db
sqlite3 selectoDB $selectoDBFile

selectoDB eval {
    DROP TABLE IF EXISTS "tablesAndFields";
    CREATE TABLE "tablesAndFields"
    (
    "tableOrView" TEXT,
    "field" TEXT
    );

    DROP VIEW IF EXISTS "inputs";
    CREATE VIEW "inputs" AS
    SELECT tableOrView AS parent
    , field
    ,'<input class="selectomaticInput" type="checkbox" onclick="doFieldChange()" name="' || tableOrView || '" value="' || field || '"></input>' AS element
    FROM "tablesAndFields";

    DROP VIEW IF EXISTS "labels";
    CREATE VIEW "labels" AS
    SELECT parent
    ,'<label>
    ' || element || '
    ' || field || '
    </label>
    ' AS element
    FROM "inputs";

    DROP VIEW IF EXISTS "fieldsets";
    CREATE VIEW "fieldsets" AS
    SELECT '<fieldset style="display: inline;">
    <legend>' || parent || '</legend>
    ' || group_concat(element, '
    ') || '
    </fieldset><br/>' AS element
    FROM "labels"
    GROUP BY parent;

    DROP VIEW IF EXISTS "page";
    CREATE VIEW "page" AS
    SELECT 1 AS seq
    ,'<!DOCTYPE html>
<html>
    <head>
      <meta name="generator" content="selectomatic"/>
      <meta name="timestamp" content="' || (SELECT datetime('now')) || '"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    </head>
    <body>
    <h2>Selectomatic!</h2>
    <h3>your user friendly interactive field selector</h3>
    ' || group_concat(element, '
    ') || '
    <textarea row="6" cols="75" id="sqlText" placeholder="sql will appear here, as if by magic"></textarea>
' AS elements
    FROM fieldsets
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
' AS elements
    UNION
    SELECT 3 AS seq
    , '    </body>
</html>
' AS elements
    ;
}
