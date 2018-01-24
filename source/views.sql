--views.sql
CREATE VIEW "inputs" AS 
SELECT tableOrView AS parent
, field
,'<input class="selectomaticInput" type="checkbox" onclick="doFieldChange()" name="' || tableOrView || '" value="' || field || '"></input>' AS element
FROM "tablesAndFields";


CREATE VIEW "labels" AS 
SELECT parent
,'<label>
' || element || '
' || field || '
</label>
' AS element
FROM "inputs";

CREATE VIEW "fieldsets" AS 
SELECT '<fieldset>
<legend>' || parent || '</legend>
' || group_concat(element, '
') || '
</fieldset>' AS element
FROM "labels"
GROUP BY parent;

CREATE VIEW "page" AS 
SELECT 1 AS seq,
'<h2>Selectomatic!</h2>
<h3>your user friendly interactive field selector for <code>example.db</code></h3>
' || group_concat(element, '
') || '
<textarea row="3" cols="75" id="sqlText" placeholder="sql will appear here, as if by magic"></textarea>
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
    console.log(fieldList);
    console.log(tableSet);
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

    var selectStr = "SELECT " + fieldList + " FROM\n" + tableStr + ";";
    console.log(selectStr);

    thingy = document.getElementById("sqlText");
    thingy.innerHTML = selectStr;
}
</script>
' AS elements;