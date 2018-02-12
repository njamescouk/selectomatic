package require sqlite3
package require Tk
source selectomaticDefinition.tcl
source ../../tcllib/menuplus.tcl

# foster-johnson.com/grid.html for sticky rowconfigure columnconfigure

bind all <Escape> { exit }

set initWindowWidth 400
set initWindowHeight 0
set curDbFile {none selected}
set selectoStatus "<Escape> to { exit }"
set selectoTitle "Selectomatic! Field Extractor"
set tableLimit 50
set checkboxRow 3
set sqlRow 2

option add *tearoff 0 


. configure -menu [menu .m] ;# . is a command?
mplus .m {&File} "&Open database" {selecto .}
mplus .m {&File} "E&xit" exit

#wm withdraw .
wm minsize . 400 200
wm deiconify .
raise .
focus -force .
wm geom . [wm geom .]
wm iconbitmap . selectoIcon.ico
wm title . $selectoTitle

# make a group for db file and grid it
set dbGroup [labelframe .dbLF -text {current database}]
grid $dbGroup -row 0 -column 0 -sticky snew

# make a label, put it in the group we've just made
set dbField [label .labDBFile -justify left -anchor w -relief ridge -textvariable curDbFile] ;# not 400 ?
pack $dbField -in $dbGroup -fill x -expand 1
set numRows 1
#################################################

set sqlTextFrame [frame .sqlFrame]
grid $sqlTextFrame -row $sqlRow -column 0 -sticky snew

set sqlTextText [tk::text .sqlText -wrap word]
pack $sqlTextText -fill x -in $sqlTextFrame 

event add <<Paste>> <Control-v>
event add <<Copy>> <Control-c>
bind Entry <<Paste>> %W
bind Entry <<Copy>> %W
#################################################

# make a frame for status bar and grid it
set statusFrameGroup [frame .statusFrame]
grid $statusFrameGroup -row $tableLimit -column 0 -sticky snew
#pack $statusFrameGroup -anchor s

# make a label shove it in frame
set statusField [label .labStatus -anchor w -relief sunken -textvariable selectoStatus]
pack $statusField -fill x -in $statusFrameGroup ;

grid [ttk::sizegrip .sz] -row $tableLimit -sticky se -column 0
#################################################

grid rowconfigure . 2 -weight 1
grid columnconfigure . 0 -weight 1

proc selecto {w} {
    global curDbFile
    if {1} {
        set curDbFile [fileDialog $w]
        if {$curDbFile eq "" } {
            global selectoStatus
            set selectoStatus {no file specified}
            return
        }
    } else {
        set curDbFile {some/other.db}
    }

    sqlite3 dbhandle $curDbFile -readonly true
    dbhandle enable_load_extension 1
    dbhandle eval {SELECT load_extension('regexp.sqlext');}
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
    close $fp

    #if {numTables > $tableLimit / 2} {
    #    exit
    #}
    if { [winfo exists .tableGroup] } { 
        destroy .tableGroup
    }

    set fp [open "selectoUI.tcl" w]
    puts $fp {global $checkboxRow}
    global checkboxRow
    selectoDB eval "SELECT stmts FROM tcl;"  anArray {
        set stmtRow "$anArray(stmts)"
        puts $fp $stmtRow
        eval $stmtRow
    }
    close $fp

    #source selectoUI.tcl
}

proc fileDialog {w} {
    set types {
        {"sqlite db files" {.db .sqlite .etilqs}}
        {"All files"       *}
    }

    set userFile [tk_getOpenFile -multiple false -filetypes $types -parent $w -typevariable "sqlite db files"]

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

proc getData {tableList fieldList} {
    #puts $tableList
    #puts $fieldList
    #puts {=====================================================}

    set fieldClause ""
    for {set i 0} {$i < [llength $fieldList]} {incr i} {
        if {$i > 0} {
            set fieldClause "$fieldClause,"
        }
        set fieldClause "$fieldClause [lindex $fieldList $i]"
    }

    set fromClause ""
    for {set i 0} {$i < [llength $tableList]} {incr i} {
        if {$i > 0} {
            set fromClause "$fromClause,"
        }
        set fromClause "$fromClause [lindex $tableList $i]"
    }

    set selectStr "SELECT DISTINCT $fieldClause FROM\n $fromClause ;";
    # puts $selectStr
    global sqlTextText
    $sqlTextText delete 1.0 end
    $sqlTextText insert 1.0  $selectStr
}
