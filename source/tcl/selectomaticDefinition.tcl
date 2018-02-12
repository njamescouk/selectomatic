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

    DROP VIEW IF EXISTS "tclTableOrView"; 
    CREATE VIEW "tclTableOrView" AS 
    SELECT tableOrView
    AS name
    , replace(replace(tableOrView, '-', '_'), substr(tableOrView, 0, 1), lower(substr(tableOrView, 1, 1))) 
    AS tclName
    FROM tablesAndFields
    GROUP BY tableOrView;

    DROP VIEW IF EXISTS "tclField"; 
    CREATE VIEW "tclField" AS 
    SELECT field
    AS name
    , replace(replace(field, '-', '_'), substr(field, 1, 1), lower(substr(field, 1, 1))) 
    AS tclName
    FROM tablesAndFields
    GROUP BY field;

    DROP VIEW IF EXISTS "inputs";
    CREATE VIEW "inputs" AS
    SELECT tableOrView AS parent
    , field
    ,'<input class="selectomaticInput" type="checkbox" onclick="doFieldChange()" name="' 
    || tableOrView 
    || '" value="' 
    || field 
    || '"/>' 
    AS element
    FROM "tablesAndFields";

    DROP VIEW IF EXISTS "labels";
    CREATE VIEW "labels" AS
    SELECT parent
    ,'<label>
    ' 
    || element 
    || '
    ' 
    || field 
    || '
    </label>
    ' AS element
    FROM "inputs";

    DROP VIEW IF EXISTS "fieldsets";
    CREATE VIEW "fieldsets" AS
    SELECT '<fieldset style="display: inline;">
    <legend>' 
    || parent 
    || '</legend>
    ' 
    || group_concat(element, '
    ') 
    || '
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
      <meta name="timestamp" content="' 
      || (SELECT datetime('now')) 
      || '"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    </head>
    <body>
    <h2>Selectomatic!</h2>
    <h3>your user friendly interactive field selector</h3>
' 
    || group_concat(element, '
') 
    || '
    <textarea row="6" cols="75" id="sqlText" placeholder="sql will appear here, as if by magic"></textarea>
' 
    AS elements
    FROM fieldsets
    UNION
    SELECT 2 AS seq
    ,'
    <script type="text/javascript">
' 
    || (SELECT code FROM scriptSrc WHERE language='javascript')
    || '</script>
' AS elements
    UNION
    SELECT 3 AS seq
    , '    </body>
</html>
' 
AS elements
;

DROP VIEW IF EXISTS "checkbuttons";
CREATE VIEW "checkbuttons" AS 
SELECT tableOrView AS parent
, field
,(SELECT tclName FROM tclTableOrView WHERE name=tableOrView)
|| (SELECT tclName FROM tclField WHERE name=field) AS varName
,'checkbutton .tableGroup.' 
|| (SELECT tclName FROM tclTableOrView WHERE name=tableOrView) 
|| '.' 
|| (SELECT tclName FROM tclField WHERE name=field)
|| ' -text "' 
|| "field" 
|| '" -variable "' 
|| (SELECT tclName FROM tclTableOrView WHERE name=tableOrView) 
|| (SELECT tclName FROM tclField WHERE name=field) 
|| '" -command doFieldChange -onvalue {"'
|| tableOrView
|| '" "'
|| field
|| '"}
pack .tableGroup.' 
|| (SELECT tclName FROM tclTableOrView WHERE name=tableOrView)
|| '.'
|| (SELECT tclName FROM tclField WHERE name=field) 
|| ' -side left'
AS checkbutton
FROM "tablesAndFields";

DROP VIEW IF EXISTS "labelframes";
CREATE VIEW "labelframes" AS 
SELECT 'set tableGroup' 
|| (SELECT tclName FROM tclTableOrView WHERE name=parent)
|| ' [labelframe .tableGroup.' 
|| (SELECT tclName FROM tclTableOrView WHERE name=parent) 
|| ' -text {' 
|| parent 
|| '}]
pack $tableGroup' 
|| (SELECT tclName FROM tclTableOrView WHERE name=parent) 
|| ' -anchor w'
AS labelFrame
FROM "labels"
GROUP BY parent;

DROP VIEW IF EXISTS "tcl"; 
CREATE VIEW "tcl" AS 
SELECT 1 AS seq,
'set tableGroupFrame [frame .tableGroup]
grid $tableGroupFrame -row $checkboxRow' AS stmts

UNION

SELECT 2 AS seq,
labelframe FROM labelframes AS stmts

UNION 

SELECT 3 AS seq,
checkbutton FROM checkbuttons

UNION 

SELECT 4 AS seq,
code FROM scriptSrc WHERE "language"='tcl'


ORDER BY seq;

DROP VIEW IF EXISTS scriptSrc;
CREATE VIEW scriptSrc AS
SELECT 
'javascript' AS language,
'
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
' AS code

UNION

SELECT
'tcl' AS language,
'proc doFieldChange {} {
    foreach {var} {'
    || (SELECT group_concat(varName, ' ') FROM checkbuttons)
||'} {
        eval "global $var"
        if {[subst $$var] ne 0} {
            foreach {table field} [subst $$var] {
                lappend fieldList "\"$table\".\"$field\""
                lappend tableList \"$table\"
            }
        }
    }
    set uniqueTableList [lsort -unique $tableList]
    getData $uniqueTableList $fieldList
    return "doing change"
 }
' 
AS code
;
}
# end of tcl
