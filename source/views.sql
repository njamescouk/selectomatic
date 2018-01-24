--views.sql
CREATE VIEW "inputs" AS 
SELECT tableOrView AS parent
, field
,'<input class="selectomaticInput" type="checkbox" onclick="doFieldChange(this)" name="' || tableOrView || '" value="' || field || '"></input>' AS element
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
<textarea id="sqlText" placeholder="sql will appear here, as if by magic"></textarea>
' AS elements
FROM fieldsets
UNION 
SELECT 2 AS seq
,'
<script type="text/javascript">
function doFieldChange(couldBeAnything)
{
    console.log (couldBeAnything.name + " " + couldBeAnything.value + " " + couldBeAnything.checked);
    selectoInputs = document.getElementsByClassName("selectomaticInput");
    for (var i = 0; i < selectoInputs.length; i += 1) 
    {
        if (selectoInputs[i].type == "checkbox")
        {
            console.log(selectoInputs[i]);
        }
    }
}
</script>
' AS elements;