package require Tk
package require sqlite3

source selectomaticDefinition.tcl

wm iconbitmap . selectoIcon.ico
wm title . Selectomatic

label .heading -font {normal -32} -justify center -text "Selectomatic\nDatabase Viewer"
pack .heading

labelframe .fileSelectorGroup -text "Select database file to open:"

entry .fileSelectorGroup.ent -width 40 
button .fileSelectorGroup.but -text "Browse ..." -command "fileDialog .fileSelectorGroup .fileSelectorGroup.ent"

pack .fileSelectorGroup.ent -side left -padx 10 -expand yes -fill x
pack .fileSelectorGroup.but -side left -padx 10 -pady 3
pack .fileSelectorGroup -fill x -padx 2c -pady 3
focus .fileSelectorGroup.ent

# end of UI ======================================================================================


proc fileDialog {w ent} {
    if {0} {
    set types {
        {"sqlite db files" {.db .sqlite .etilqs}}
        {"All files"       *}
    }

    set userFile [tk_getOpenFile -multiple false -filetypes $types -parent $w -typevariable "sqlite db files"]

    if {[string compare $userFile ""]} {
        $ent delete 0 end
        $ent insert 0 $userFile
        $ent xview end

        # and off we go
        kickOff $userFile
    }
}
    # kickOff {I:\usr\NIK\DOM\hobbies\politics\medconfidential\phe\PHE.db}
    kickOff {I:\usr\NIK\DOM\hobbies\politics\medconfidential\nhsDataRelease\2017_09to11\release2017_09-11.db}
}

proc kickOff { dbFile } {
    puts "line 45: $dbFile"
    sqlite3 dbhandle $dbFile -readonly true
    dbhandle enable_load_extension 1
    dbhandle eval {SELECT load_extension('regexp.sqlext');}
    showFieldSelectors dbhandle
}

proc showFieldSelectors {dbHandle} {
    puts "line 51"
    set tablesAndViews [dbhandle eval {SELECT name FROM sqlite_master WHERE type='table' OR type='view' ;}]
    puts "line 53: $tablesAndViews"
    foreach tOrV $tablesAndViews {
        showFieldSelector $dbHandle $tOrV
    }
    exit 1
}

proc showFieldSelector {dbHandle name} {
    puts "line 66: $name"
    set query "PRAGMA table_info (\"$name\");"
    puts "line 68: $query"
    # puts "line 65 [dbhandle eval $query]"
    dbhandle eval {$query} thisIsAnArray {
        parray thisIsAnArray
        puts line 68: $thisIsAnArray(*)
    }
    #puts "line 64 $thisIsAnArray"
    #foreach fld $thisIsAnArray {
    #    puts =============================================
    #    makeSelector $fld
    #}
}

proc makeSelector {field} {
    puts "line 74: $field"
}

proc unknown {} {
    puts {************** BARF ******************}
}