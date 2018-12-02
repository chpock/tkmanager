#!/usr/bin/env wish

# tkmanager -
# Copyright (C) 2018 Konstantin Kushnir <chpock@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.

lappend auto_path [file join [pwd] ..] [file join [pwd] tkcon]

package require tkcon

tkcon show

package require tkmanager

lappend ::tkm::iconPath [file join [pwd] icons famfamfam]

tkm::packer {

    set ::gDebug 0

    tkm::checkbutton -anchor w -text "Debug mode" -variable ::gDebug \
        -pad 10

    tkm::separator -fill x -expand 1 -padx 10 -pady {0 10}

}

foreach fn [lsort -dict [glob -type f -directory [pwd] "??_*.tcl"]] {
    source $fn
}; unset fn

# -------------------------------------------------------------------------------

tkm::packer {

    tkm::separator -fill x -expand 1 -padx 10 -pady {10 0}

    tkm::button -text "Exit" -image [tkm::icon cancel] \
        -pad 10 -command exit

}

after 10 [list focus .]