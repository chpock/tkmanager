::if no { -*- mode: tcl; tab-width: 4; -*-
:: vim: set syntax=tcl shiftwidth=4:
@wish "%~f0" %*
@goto :eof
}

cd [file dirname [info script]]
source [file join [pwd] "[file rootname [file tail [info script]]].tcl"]
