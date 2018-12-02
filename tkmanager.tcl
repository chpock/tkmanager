# tkmanager -
# Copyright (C) 2018 Konstantin Kushnir <chpock@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.

package provide tkmanager 0.0.1

package require Tk
package require tile

namespace eval ::tkm {

    variable UID
    variable iconPath

    variable state

    variable DebugWidgets

    set iconPath [list]
    set DebugWidgets [list]

    namespace eval icon { }

    proc packer { args } {
        variable state
        variable DebugWidgets

        set debug 0

        set script [lindex $args end]
        set args   [lrange $args 0 end-1]

        for { set i 0 } { $i < [llength $args] } { incr i } {
            switch -exact -- [lindex $args $i] {
                -path {
                    set path [lindex $args [incr i]]
                }
                -debug {
                    set debug [lindex $args [incr i]]
                }
                -newwindow {
                    set newwindow 1
                }
                -title {
                    set title [lindex $args [incr i]]
                }
                default {
                    return -code error "::tkm::packer - Unknown option - '[lindex $args $i]'"
                }
            }
        }

        if { ![info exists path] || $path eq "" } {
            set path "."
        }

        if { [info exists newwindow] } {
            toplevel $path
        }

        if { [info exists title] } {
            wm title $path $title
        }

        if { [info exists state] } {

            set savedState $state

            if { [dict get $state debug] } {
                set debug 1
            }

        }

        set state [list \
            column   0       \
            row      0       \
            defaults ""      \
            debug    $debug  \
            path     $path   \
        ]

        set result [uplevel 1 $script]

        if { $debug } {

            set toplevel [winfo toplevel $path]

            if {
                    ![dict exists $DebugWidgets $toplevel] ||
                    ![winfo exists [dict get $DebugWidgets $toplevel boundsN]]
            } {
                dict set DebugWidgets $toplevel boundsN [::tk::frame "${toplevel}.__boundsN" -bg "#ff0000"]
                dict set DebugWidgets $toplevel boundsW [::tk::frame "${toplevel}.__boundsW" -bg "#ff0000"]
                dict set DebugWidgets $toplevel boundsE [::tk::frame "${toplevel}.__boundsE" -bg "#ff0000"]
                dict set DebugWidgets $toplevel boundsS [::tk::frame "${toplevel}.__boundsS" -bg "#ff0000"]
                dict set DebugWidgets $toplevel boundsPadN [::tk::frame "${toplevel}.__boundsPadN" -bg "#00ff00"]
                dict set DebugWidgets $toplevel boundsPadW [::tk::frame "${toplevel}.__boundsPadW" -bg "#00ff00"]
                dict set DebugWidgets $toplevel boundsPadE [::tk::frame "${toplevel}.__boundsPadE" -bg "#00ff00"]
                dict set DebugWidgets $toplevel boundsPadS [::tk::frame "${toplevel}.__boundsPadS" -bg "#00ff00"]
                dict set DebugWidgets $toplevel current ""
            }

        }

        if { [info exists savedState] } {
            set state $savedState
        } else {
            unset state
        }

        return $result

    }

    proc var { {suffix {}} } {

        variable state
        variable UID

        set parent [dict get $state path]

        if { $suffix eq "" } {
            set suffix [incr UID]
        }

        return "::tkm::(${parent},variable,${suffix})"

    }

    proc parent { } {
        variable state
        return [dict get $state path]
    }

    proc last { } {
        variable state
        return [dict get $state wid]
    }

    proc defaults { args } {
        variable state

        if { [llength $args] } {
            dict set state defaults $args
        }

        return [dict get $state defaults]
    }

    proc DebugEnter { wid } {
        variable DebugWidgets

        set toplevel [winfo toplevel $wid]

        if { [dict get $DebugWidgets $toplevel current] eq $wid } {
            return
        }
        dict set DebugWidgets $toplevel current $wid

        set procFindProperty [list apply {{ wid property } {

            set result 0

            while { $wid ne [winfo toplevel $wid] } {
                incr result [winfo $property $wid]
                set wid [winfo parent $wid]
            }

            return $result

        }}]

        set x [{*}$procFindProperty $wid x]
        set y [{*}$procFindProperty $wid y]
        set h [winfo height $wid]
        set w [winfo width $wid]
        set manager [winfo manager $wid]

        switch -exact -- $manager {
            grid { set managerInfo [grid info $wid] }
            pack { set managerInfo [pack info $wid] }
            default { set managerInfo [list] }
        }

        puts "ENTER\[[winfo class $wid] $wid\] x:$x y:$y h:$h w:$w toplevel:$toplevel manager:$manager \[$managerInfo\]"

        if { ![dict exists $managerInfo -padx] } {
            dict set managerInfo -padx {0 0}
        } elseif { [llength [dict get $managerInfo -padx]] == 1 } {
            dict set managerInfo -padx [list [dict get $managerInfo -padx] [dict get $managerInfo -padx]]
        }

        if { ![dict exists $managerInfo -pady] } {
            dict set managerInfo -pady {0 0}
        } elseif { [llength [dict get $managerInfo -pady]] == 1 } {
            dict set managerInfo -pady [list [dict get $managerInfo -pady] [dict get $managerInfo -pady]]
        }

        set padxW [lindex [dict get $managerInfo -padx] 0]
        set padxE [lindex [dict get $managerInfo -padx] 1]
        set padyN [lindex [dict get $managerInfo -pady] 0]
        set padyS [lindex [dict get $managerInfo -pady] 1]

        set padx [expr { $x - $padxW }]
        set pady [expr { $y - $padyN }]
        set padw [expr { $w + $padxW + $padxE }]
        set padh [expr { $h + $padyN + $padyS }]


        place [dict get $DebugWidgets $toplevel boundsPadN] \
            -x $padx -y $pady -height 1 -width $padw
        place [dict get $DebugWidgets $toplevel boundsPadW] \
            -x $padx -y $pady -height $padh -width 1
        place [dict get $DebugWidgets $toplevel boundsPadE] \
            -x [expr { $padx + $padw }] -y $pady -height $padh -width 1
        place [dict get $DebugWidgets $toplevel boundsPadS] \
            -x $padx -y [expr { $pady + $padh }] -height 1 -width $padw
        raise [dict get $DebugWidgets $toplevel boundsPadN]
        raise [dict get $DebugWidgets $toplevel boundsPadE]
        raise [dict get $DebugWidgets $toplevel boundsPadW]
        raise [dict get $DebugWidgets $toplevel boundsPadS]

        place [dict get $DebugWidgets $toplevel boundsN] \
            -x $x -y $y -height 1 -width $w
        place [dict get $DebugWidgets $toplevel boundsW] \
            -x $x -y $y -height $h -width 1
        place [dict get $DebugWidgets $toplevel boundsE] \
            -x [expr { $x + $w }] -y $y -height $h -width 1
        place [dict get $DebugWidgets $toplevel boundsS] \
            -x $x -y [expr { $y + $h }] -height 1 -width $w
        raise [dict get $DebugWidgets $toplevel boundsN]
        raise [dict get $DebugWidgets $toplevel boundsE]
        raise [dict get $DebugWidgets $toplevel boundsW]
        raise [dict get $DebugWidgets $toplevel boundsS]

    }

    proc DebugLeave { wid } {

        variable DebugWidgets

        set parent [winfo parent $wid]
        set toplevel [winfo toplevel $wid]

        if { $parent ne $toplevel } {
            DebugEnter $parent
        } else {

            place forget [dict get $DebugWidgets $toplevel boundsN]
            place forget [dict get $DebugWidgets $toplevel boundsE]
            place forget [dict get $DebugWidgets $toplevel boundsW]
            place forget [dict get $DebugWidgets $toplevel boundsS]

            place forget [dict get $DebugWidgets $toplevel boundsPadN]
            place forget [dict get $DebugWidgets $toplevel boundsPadE]
            place forget [dict get $DebugWidgets $toplevel boundsPadW]
            place forget [dict get $DebugWidgets $toplevel boundsPadS]

            dict set DebugWidgets $toplevel current ""

        }

    }

    proc icon { name } {

        variable iconPath

        set icon "[namespace current]::icon::$name"

        if { [llength [info commands $icon]] } {
            return $icon
        }

        foreach path $iconPath {
            if { [file exists [set fn [file join $path "${name}.png"]]] } {
                set format "png"
                break
            } elseif { [file exists [set fn [file join $path "${name}.gif"]]] } {
                set format "gif"
                break
            }
            unset fn
        }

        if { ![info exists fn] } {
            return -code error "Could not find the image file for the icon: '$name' (search path: '[join $iconPath {', '}]')"
        }

        return [image create photo $icon -file $fn -format $format]

    }

    proc centerWindow { window {relative screen} } {

        variable UID

        wm withdraw $window

        update idletasks

        set width  [winfo reqwidth  $window]
        set height [winfo reqheight $window]

        if { $relative eq "screen" } {

            if { [catch {

                package require twapi

                set workarea [twapi::get_display_monitor_info \
                    [twapi::get_display_monitor_from_window \
                        $window -default nearest \
                    ] \
                ]

                set workarea [dict get $workarea -workarea]

                set x [expr { ([lindex $workarea 2] - $width) / 2 }]
                set y [expr { ([lindex $workarea 3] - $height) / 2 }]

            }] } {

                set x [expr { ([winfo screenwidth $window] - $width) / 2}]
                set y [expr { ([winfo screenheight $window] - $height) / 2}]
                # the above commands gives screen resolution, but not
                # actual workspace size
                #toplevel [set testWin ".__test_screen_size__[incr UID]"]
                #wm withdraw $testWin
                #wm state $testWin zoomed
                #update idletasks
                #set x [expr { ([winfo width $testWin] - $width) / 2 }]
                #set y [expr { ([winfo height $testWin] - $height) / 2 }]
                #destroy $testWin
                # this solution gives blinked window

            }

        } else {

            set x [expr { [winfo x $relative] + ([winfo width $relative] - $width) / 2 }]
            set y [expr { [winfo y $relative] + ([winfo height $relative] - $height) / 2 }]

        }

        if { $x < 0 } { set x 1 }
        if { $y < 0 } { set y 1 }

        wm geometry $window ${width}x${height}+${x}+${y}
        wm deiconify $window

    }

    proc _checkbutton { mode } {

        upvar args_widget args_widget

        if { $mode eq "init" } {
            if { ![dict exists $args_widget -variable] } {
                dict set args_widget -variable AUTO
            }
        }

    }

    proc _radiobutton { mode } {

        upvar args_widget args_widget

        if { $mode eq "init" } {
            if { ![dict exists $args_widget -variable] } {
                dict set args_widget -variable AUTO
            }
        }

    }

    proc _entry { mode } {

        upvar args_widget args_widget

        if { $mode eq "init" } {
            if { ![dict exists $args_widget -textvariable] } {
                dict set args_widget -textvariable AUTO
            }
        }

    }

    proc _combobox { mode } {

        upvar args_widget args_widget

        if { $mode eq "init" } {
            if { ![dict exists $args_widget -textvariable] } {
                dict set args_widget -textvariable AUTO
            }
        }

    }

    proc _button { mode } {

        upvar args_widget args_widget

        if { $mode eq "init" } {

            if {
                [dict exists $args_widget -text] &&
                [dict exists $args_widget -image] &&
                ![dict exists $args_widget -compound]
            } {
                dict set args_widget -compound left
            }

        }

    }

    proc _labelframe { mode } {

        upvar args_widget args_widget

        if { $mode eq "init" } {

            if { [dict exists $args_widget -image] } {

                set labelFrame [frame -- {

                    if { [dict exists $args_widget -text] } {

                        if { ![dict exists $args_widget -compound] } {
                            dict set args_widget -compound left
                        }

                        tkm::label \
                            -style    TKMLabelframeLabel.TLabel         \
                            -image    [dict get $args_widget -image]    \
                            -text     [dict get $args_widget -text]     \
                            -compound [dict get $args_widget -compound]

                    } else {
                        tkm::label -image [dict get $args_widget -image]
                    }

                }]

                dict set args_widget -labelwidget $labelFrame
                dict unset args_widget -image
                dict unset args_widget -text
                dict unset args_widget -compound

            }

        }

    }

    proc SimpleWidget { widget args } {

        variable state

        FindWidgetId
        ParseArguments

        if { [llength [info commands "::tkm::_$widget"]] } {
            set customCmd "::tkm::_$widget"
        }

        if { [info exists customCmd] } {
            $customCmd init
        }

        if { [dict exists $args_widget -variable] && [dict get $args_widget -variable] eq "AUTO" } {
            dict set args_widget -variable "::tkm::(${wid},value)"
        }

        if { [dict exists $args_widget -textvariable] && [dict get $args_widget -textvariable] eq "AUTO" } {
            dict set args_widget -textvariable "::tkm::(${wid},text)"
        }

        if { [llength [info commands ::ttk::$widget]] } {
            set widget "::ttk::$widget"
        } elseif { [llength [info commands ::tk::$widget]] } {
            set widget "::tk::$widget"
        }

        if { [info exists customCmd] } {
            $customCmd create
        }

        # the widget could be created by custom cmd
        if { ![info exists result] } {
            set result [uplevel 1 [list $widget $wid {*}$args_widget]]
        }

        dict set state wid $result

        if { [dict get $state debug] } {
            bind $result <Enter> { ::tkm::DebugEnter %W }
            bind $result <Leave> { ::tkm::DebugLeave %W }
        }

        if { [info exists customCmd] } {
            $customCmd post
        }

        if { $args_add ne "" } {
            uplevel 1 [list ::tkm::packer -path $wid $args_add]
        }

        ApplyPack

        return $result

    }

    proc ApplyPack { } {

        variable state

        upvar args_pack args_pack
        upvar wid       wid

        if { [dict exists $args_pack -nopack] } {
            return
        }

        if { [dict exists $args_pack -row] || [dict exists $args_pack -column] } {

            if { [dict exists $args_pack -row] } {
                if { [dict get $args_pack -row] eq "+" } {
                    dict set state row [expr { [dict get $state row] + 1 }]
                    if { ![dict exists $args_pack -column] } {
                        dict set state column 0
                    }
                } else {
                    dict set state row [dict get $args_pack -row]
                }
            }
            dict set args_pack -row [dict get $state row]

            if { [dict exists $args_pack -column] } {
                if { [dict get $args_pack -column] eq "+" } {
                    dict set state column [expr { [dict get $state column] + 1 }]
                } else {
                    dict set state column [dict get $args_pack -column]
                }
            }
            dict set args_pack -column [dict get $state column]

            if { ![dict exists $args_pack -sticky] } {
                if { [dict exists $args_pack -fill] } {
                    switch -exact -- [dict get $args_pack -fill] {
                        x    { dict set args_pack -sticky "ew" }
                        y    { dict set args_pack -sticky "ns" }
                        both { dict set args_pack -sticky "nsew" }
                    }
                    dict unset args_pack -fill
                }
            }

            grid $wid {*}$args_pack

            if { [dict exists $args_pack -columnspan] } {
                dict set state column [expr {
                    [dict get $state column] + [dict get $args_pack -columnspan] - 1
                }]
            }

        } else {

            pack $wid {*}$args_pack

        }

    }

    proc FindWidgetId { } {

        variable state
        variable UID

        upvar args   args
        upvar wid    wid
        upvar parent parent

        if { [string index [lindex $args 0] 0] eq "." } {
            set wid [lindex $args 0]
            set args [lrange $args 1 end]
        } else {
            set wid ".[incr UID]"
        }

        set parent [dict get $state path]

        if { $parent ne "." && ![string match "${parent}.*" $wid] } {
            set wid "${parent}$wid"
        }

    }

    proc ParseArguments { } {

        variable state

        upvar args        args
        upvar args_pack   args_pack
        upvar args_widget args_widget
        upvar args_add    args_add

        set args [concat [dict get $state defaults] $args]

        set args_pack   [list]
        set args_widget [list]
        set args_add    ""

        for { set i 0 } { $i < [llength $args] } { incr i } {

            set param [lindex $args $i]

            if { $param eq "--" } {
                set args_add [lindex $args [incr i]]
            } elseif { $param in {
                -after  -anchor
                -before -expand
                -fill   -in
                -ipadx  -ipady
                -padx   -pady
                -side

                -column -columnspan
                -row    -rowspan
                -sticky
            } } {

                dict set args_pack $param [lindex $args [incr i]]

            } elseif { $param eq "-nopack" } {

                dict set args_pack $param 1

            } elseif { $param in {-pad -ipad} } {

                set val [lindex $args [incr i]]

                if { ![llength $val] } {
                    return -code error "tkm::ParseArguments: '$param' requires non empty list (args: $args)"
                } elseif { [llength $val] > 2 } {
                    return -code error "tkm::ParseArguments: '$param' number of parameters more than 2 (args: $args)"
                } elseif { [llength $val] == 1 } {
                    dict set args_pack "${param}x" $val
                    dict set args_pack "${param}y" $val
                } else {
                    dict set args_pack "${param}x" [lindex $val 0]
                    dict set args_pack "${param}y" [lindex $val 1]
                }

            } else {

                dict set args_widget $param [lindex $args [incr i]]

            }

        }

    }

}

{*}[list apply {{} {

    foreach widget {
        button
        checkbutton
        combobox
        entry
        frame
        label
        labelframe
        menubutton
        notebook
        panedwindow
        progressbar
        radiobutton
        scale
        scrollbar
        separator
        sizegrip
        spinbox
        treeview

        listbox
    } {
        proc "::tkm::$widget" { args } {

            set widget [lindex [info level 0] 0]

            if { [namespace qualifiers $widget] in {tkm ::tkm} } {
                set widget [namespace tail $widget]
            }

            tailcall SimpleWidget $widget {*}$args

        }
    }

    set style [list -space 7]

    if { [set fg [ttk::style lookup TLabelframe.Label -foreground]] ne "" } {
        lappend style -foreground $fg
    }

    ttk::style configure TKMLabelframeLabel.TLabel {*}$style

}}]
