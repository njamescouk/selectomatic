# from DKF
proc mplus {root head name {cmd ""} } {
    if {![winfo exists $root.m$head]} {
        foreach {l u} [::tk::UnderlineAmpersand $head] break
        $root add cascade -label $l -underline $u -menu [menu $root.m$head -tearoff 0]
    }

    if [regexp ^-+$ $name] {
        $root.m$head add separator
    } else {
        foreach {l u} [::tk::UnderlineAmpersand $name] break
        $root.m$head add command -label $l -underline $u -comm $cmd
    }
}

if {0} {
    example use:

    pack [text .t]
    . configure -menu [menu .m]
    mplus .m &File &Open {.t insert end "opened\n"}
    mplus .m File E&xit exit
    pack [text .t1 -wrap word] -fill both -expand 1
}