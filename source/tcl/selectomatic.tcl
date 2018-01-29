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

# end of UI ======================================================================================

proc selecto {w ent} {
    puts {line 25: selecto}
    set dbFile [fileDialog w ent]
    puts "line 27: $dbFile"
    if {$dbFile eq "" } {
        puts {no file specified}
        exit 20
    }

    sqlite3 dbhandle $dbFile -readonly true
    dbhandle enable_load_extension 1
    dbhandle eval {SELECT load_extension('regexp.sqlext');}
    puts "line 36: sqlite version [dbhandle version]"
    makeSelectoDB dbhandle
}

proc fileDialog {w ent} {
    if {0} { "################################################"
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
"################################################"}
    set userFile {I:\usr\NIK\DOM\hobbies\politics\medconfidential\nhsDataRelease\2017_09to11\release2017_09-11.db}

    return $userFile
}

proc makeSelectoDB {db} {
    puts "line 61"
    set tablesAndViews [$db eval {SELECT name FROM sqlite_master WHERE type='table' OR type='view' ;}]
    puts "line 63: $tablesAndViews"
    foreach tOrV $tablesAndViews {
        showFieldSelector $db $tOrV
    }
    exit 1
}

proc showFieldSelector {db name} {
    puts "line 71: $name"
    set sql "PRAGMA table_info (\"$name\");"
    # set query "PRAGMA table_info ($name);"
    puts "line 74: $sql"

puts ====================================================\n
    $db eval $sql ;#anArray { parray anArray }
    puts "line 78: [$db eval $sql]" ;#anArray { parray anArray }
    $db eval $sql anArray { parray $anArray }
    puts [$db errorcode]
puts ====================================================\n
    #$db eval "PRAGMA table_info (\"$name\");" anArray { parray anArray }
    exit 1
    #puts "line 64 $thisIsAnArray"
    #foreach fld $thisIsAnArray {
    #    puts =============================================
    #    makeSelector $fld
    #}
}

proc makeSelector {field} {
    puts "line 90: $field"
}

proc unknown {} {
    puts {************** BARF ******************}
}