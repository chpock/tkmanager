# tkmanager -
# Copyright (C) 2018 Konstantin Kushnir <chpock@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.

lappend auto_path [file join [pwd] ..] [file join [pwd] tkcon]

package require tkmanager

lappend ::tkm::iconPath [file join [pwd] icons famfamfam]

package require tkcon

tkcon show

proc openSettings { } {

    if { [winfo exists .settings] } {
        wm deiconify .settings
        focus .settings
        return
    }

    tkm::packer -debug -path .settings -newwindow -title "Settings" {

        set action [list apply {{ window action varSize } {

            puts "Action: $action Size: [set $varSize]"

            if { $action in {ok apply} } {
                set ::gSize [set $varSize]
            }

            if { $action in {ok close} } {
               destroy $window
            }

        }} [tkm::parent]]

        tkm::labelframe -text "Button Size:" -image [tkm::icon arrow_out] -pad 10 -ipady 3 -side left -anchor n -- {

            tkm::defaults -fill both -padx 5 -pady 3

            set varSize [tkm::autovar size]

            tkm::radiobutton -text "16px" -variable $varSize -value "16" -column 0
            tkm::radiobutton -text "32px" -variable $varSize -value "32" -column +
            tkm::radiobutton -text "48px" -variable $varSize -value "48" -column +

            tkm::radiobutton -text "64px"  -variable $varSize -value "64"  -column 0 -row +
            tkm::radiobutton -text "128px" -variable $varSize -value "128" -column +

        }

        tkm::frame -side right -padx {0 10} -pady 10 -- {

            tkm::defaults -padx 5 -pady 3

            tkm::button -text "OK"    -image [tkm::icon tick]   \
                -command [concat $action [list ok    $varSize]]
            tkm::button -text "Close" -image [tkm::icon cross]  \
                -command [concat $action [list close $varSize]]
            tkm::button -text "Apply" -image [tkm::icon cog_go] \
                -command [concat $action [list apply $varSize]]

        }

        set $varSize $::gSize

    }

}

tkm::packer {

    set ::gSize 16

    tkm::frame -- {
        tkm::label -text "Open:" -side left -pad 10
        tkm::button -text "Settings" -side right -pad 10 -padx {0 10} -command openSettings
    }

    tkm::separator -fill x -expand 1 -padx 10

    tkm::button -text "Exit" -pad 10 -command exit

}
