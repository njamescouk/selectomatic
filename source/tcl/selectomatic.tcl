package require Tk
package require sqlite3

wm iconbitmap . selectoIcon.ico
wm title . Selectomatic

label .heading -font {normal -32} -justify center -text "Selectomatic\nDatabase Viewer"
pack .heading

set inputGroup [labelframe .fileSelectorGroup -text "Select database file to open:"]

entry $inputGroup.ent -width 40
button $inputGroup.but -text "Browse ..." -command "fileDialog $inputGroup $inputGroup.ent"
puts [$inputGroup.ent get]
pack $inputGroup.ent -side left -padx 10 -expand yes -fill x
pack $inputGroup.but -side left -padx 10 -pady 3
pack $inputGroup -fill x -padx 2c -pady 3

proc fileDialog {w ent} {
    #   Type names      Extension(s)    Mac File Type(s)
    #
    #---------------------------------------------------------
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

}
