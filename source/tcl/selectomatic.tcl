package require Tk
package require sqlite3

source selectomaticDefinition.tcl

wm iconbitmap . selectoIcon.ico
wm title . Selectomatic

label .heading -font {normal -32} -justify center -text "Selectomatic\nDatabase Viewer"
pack .heading

labelframe .fileSelectorGroup -text "Select database file to open:"

entry .fileSelectorGroup.ent -width 40 
button .fileSelectorGroup.but -text "Browse ..." -command "selecto .fileSelectorGroup .fileSelectorGroup.ent"

pack .fileSelectorGroup.ent -side left -padx 10 -expand yes -fill x
pack .fileSelectorGroup.but -side left -padx 10 -pady 3
pack .fileSelectorGroup -fill x -padx 2c -pady 3
focus .fileSelectorGroup.ent

proc selecto {w ent} {
    set dbFile [fileDialog $w $ent]
    # puts "line 26: $dbFile"
    if {$dbFile eq "" } {
        puts {no file specified}
        exit 20
    }

    sqlite3 dbhandle $dbFile -readonly true
    dbhandle enable_load_extension 1
    dbhandle eval {SELECT load_extension('regexp.sqlext');}
    # puts "line 35: sqlite version [dbhandle version]"
    makeSelectoDB dbhandle

    set fp [open "selectomatic.html" w]
    global selectoDB
    set page [selectoDB eval "SELECT elements FROM page ORDER BY seq;"]
    selectoDB eval "SELECT elements FROM page ORDER BY seq;" anArray {
        set elementRow "$anArray(elements)"
        #puts $elementRow
        puts $fp $elementRow
    }

    flush $fp
}

proc fileDialog {w ent} {
    set types {
        {"sqlite db files" {.db .sqlite .etilqs}}
        {"All files"       *}
    }

    set userFile [tk_getOpenFile -multiple false -filetypes $types -parent $w -typevariable "sqlite db files"]

    if {[string compare $userFile ""]} {
        $ent delete 0 end
        $ent insert 0 $userFile
        $ent xview end
    }

    return $userFile
}

proc makeSelectoDB {db} {
    set tablesAndViews [$db eval {SELECT name FROM sqlite_master WHERE type='table' OR type='view' ;}]
    foreach tOrV $tablesAndViews {
        writeTableOrView $db $tOrV
    }
}

proc writeTableOrView {db tOrVName} {
    #puts "$tOrVName"
    set sql "PRAGMA table_info (\"$tOrVName\");"

    $db eval $sql anArray { 
        set insertSql "INSERT INTO tablesAndFields (\"tableOrView\", \"field\") VALUES ('$tOrVName', '$anArray(name)');"
        #puts $insertSql
        global selectoDB
        selectoDB eval $insertSql 
    }
}

if {0} {
    proc unknown {arg args} {
        puts "================== BARF ======================"
        puts $arg

        foreach thing $args {
            puts $thing
        }
    }
}