# tkmanager -
# Copyright (C) 2018 Konstantin Kushnir <chpock@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.

proc openBaseDemo { } {

    set window ".[namespace tail [lindex [info level 0] 0]]"

    if { [winfo exists $window] } {
        wm deiconify $window
        focus $window
        return
    }

    tkm::packer -debug $::gDebug -path $window -newwindow -title "Base Demo" {

        tkm::labelframe -text "Frame Reliefs" -pad 13 -- {

            tkm::defaults -fill both -pad 5

            tkm::frame -relief flat -- {

                tkm::label -text "Relief: flat" -pad 5

            } -column 0 -padx {10 5}

            tkm::frame -relief groove -- {

                tkm::label -text "Relief: groove" -pad 5

            } -column +

            tkm::frame -relief raised -- {

                tkm::label -text "Relief: raised" -pad 5

            } -column + -padx {5 10}

            tkm::frame -relief ridge -- {

                tkm::label -text "Relief: ridge" -pad 5

            } -row + -pady {5 10} -padx {10 5}

            tkm::frame -relief solid -- {

                tkm::label -text "Relief: solid" -pad 5

            } -column + -pady {5 10}

            tkm::frame -relief sunken -- {

                tkm::label -text "Relief: sunken" -pad 5

            } -column + -pady {5 10} -padx {5 10}

        }

        tkm::separator -orient horizontal -fill x -padx 10

        tkm::button -text "Close" -image [tkm::icon cross] \
            -command [list destroy [tkm::parent]] \
            -pad 13

        tkm::centerWindow [tkm::parent]

    }

}


tkm::packer {

    set ::gButtonSize 16

    tkm::frame -fill x -pad 5 -- {
        tkm::label -text "Base demo:" -side left -padx 10 -anchor w
        tkm::button -text "Open" -image [tkm::icon application_go] \
            -side right -padx {0 10} -anchor e \
            -command openBaseDemo
    }

}
