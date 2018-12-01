#!/usr/bin/env wish

cd [file dirname [info script]]
source [file join [pwd] "[file rootname [file tail [info script]]].tcl"]
