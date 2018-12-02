# tkmanager -
# Copyright (C) 2018 Konstantin Kushnir <chpock@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.

proc openSettingsWeather { } {

    set window ".[namespace tail [lindex [info level 0] 0]]"

    if { [winfo exists $window] } {
        wm deiconify $window
        focus $window
        return
    }

    tkm::packer -debug $::gDebug -path $window -newwindow -title "Settings" {

        set action [list apply {{ window action varSize } {

            puts "Action: $action Size: [set $varSize]"

            if { $action in {ok apply} } {
                set ::gSize [set $varSize]
            }

            if { $action in {ok close} } {
               #destroy $window
            }

        }} [tkm::parent]]

        tkm::labelframe -text "Location:" -image [tkm::icon world_go] \
            -padx 10 -pady 13 -fill both -expand 1 -- {

            tkm::defaults -fill both -padx 5 -pady 3

            set varLocationType [tkm::var locType]

            set wSearchRadioAuto [tkm::radiobutton -text "Auto" \
                -variable $varLocationType -value "auto" \
                -column 0 -columnspan 3]

            set wSearchRadioSpecific [tkm::radiobutton -text "Specific:" \
                -variable $varLocationType -value "specific" \
                -row +]

            set varLocationCurrent [tkm::var]

            set wLocationCurrent [tkm::label \
                -font [concat [font configure TkTextFont] -weight bold] \
                -column + -columnspan 2]

            set varSearchEntry [tkm::var]

            set wSearchEntry [tkm::entry -textvariable $varSearchEntry \
                -row + -columnspan 2]

            set wSearchButton [tkm::button -text "Search" \
                -column +]

            tkm::frame -row + -columnspan 3 -- {

                tkm::defaults -fill both

                set wSearchListbox [tkm::listbox -height 5 \
                    -yscrollcommand [list "[tkm::parent].sby" set] \
                    -column 0]

                tkm::scrollbar .sby -command [list $wSearchListbox yview] -column +

                grid columnconfigure [tkm::parent] 0 -weight 1
                grid rowconfigure [tkm::parent] 0 -weight 1

            } -pady {3 10}

            grid columnconfigure [tkm::parent] 1 -weight 1

        }

        tkm::labelframe -text "Parameters:" -image [tkm::icon wrench] \
            -pady {0 13} -padx 10 -fill x -- {

            tkm::defaults -pady {4 8} -padx 5

            tkm::label -text "Temperature units:" \
                -side left -padx {8 2}

            set varParamTempUnits [tkm::var]

            tkm::radiobutton -text "Celsius" -variable $varParamTempUnits -value "C" \
                -side left
            tkm::radiobutton -text "Fahrenheit" -variable $varParamTempUnits -value "F" \
                -side left -padx {5 8}

        }

        tkm::labelframe -text "Visible Elements:" -image [tkm::icon eye] \
            -pady {0 13} -padx 10 -fill x -- {

            tkm::defaults -padx 8 -pady 2

            set varVisibleLocation [tkm::var]
            set varVisibleUpdate   [tkm::var]
            set varVisibleForecast [tkm::var]
            set varVisibleForecastDays  [tkm::var]
            set varVisibleForecastIcons [tkm::var]
            set varVisibleForecastTemp  [tkm::var]

            tkm::checkbutton -text "Current Location" -variable $varVisibleLocation \
                -anchor w -pady {5 2}
            tkm::checkbutton -text "Last Update" -variable $varVisibleUpdate \
                -anchor w
            set wVisForecast [tkm::checkbutton -text "Forecast" \
                -variable $varVisibleForecast \
                -anchor w]
            set wVisForecastDays [tkm::checkbutton -text "Forecast - Day Name" \
                -variable $varVisibleForecastDays \
                -anchor w]
            set wVisForecastIcons [tkm::checkbutton -text "Forecast - Icon" \
                -variable $varVisibleForecastIcons \
                -anchor w]
            set wVisForecastTemp [tkm::checkbutton -text "Forecast - Temperature" \
                -variable $varVisibleForecastTemp \
                -anchor w -pady {2 8}]

        }

        tkm::separator -orient horizontal -fill x -padx 15

        tkm::frame -side bottom -padx 10 -pady 10 -anchor e -- {

            tkm::defaults -padx 5 -pady 3 -side left

            set wActionOk    [tkm::button -text "OK"    -image [tkm::icon tick]]
            set wActionClose [tkm::button -text "Close" -image [tkm::icon cross]]
            set wActionApply [tkm::button -text "Apply" -image [tkm::icon cog_go]]

        }

        wm resizable [tkm::parent] 0 0

        tkm::centerWindow [tkm::parent]

        $wSearchButton configure -command [list apply {{
            wSearchListbox wSearchButton wSearchRadioAuto varSearchEntry
        } {

           $wSearchButton state "disabled"
           $wSearchRadioAuto state "disabled"
           update idle

           puts "proc:lb : $wSearchListbox"
           puts "proc:var: $varSearchEntry"
           puts "proc:val: [set $varSearchEntry]"

           $wSearchListbox delete 0 end

           set count [expr { round(rand()*20) + 10 }]
           for { set i 0 } { $i < $count } { incr i } {
               $wSearchListbox insert end "Search: [set $varSearchEntry] : $i : [expr { rand() } ] : more text"
           }

           $wSearchButton state "!disabled"
           $wSearchRadioAuto state "!disabled"

        }} $wSearchListbox $wSearchButton $wSearchRadioAuto $varSearchEntry]

        $wSearchEntry configure -validate all -validatecommand [list apply {{ wSearchEntry wSearchButton value } {

            if { [string trim $value] eq "" } {
                $wSearchButton state "disabled"
            } else {
                $wSearchButton state "!disabled"
            }

        return 1

        }} $wSearchEntry $wSearchButton %P]

        $wSearchRadioAuto configure -command [list apply {{ wSearchEntry wSearchButton wSearchListbox } {

            $wSearchEntry   state "disabled"
            $wSearchButton  state "disabled"
            $wSearchListbox configure -state "disabled"

        }} $wSearchEntry $wSearchButton $wSearchListbox]

        $wSearchRadioSpecific configure -command [list apply {{ wSearchEntry wSearchButton wSearchListbox } {

            $wSearchEntry   state "!disabled"
            $wSearchButton  state "!disabled"
            $wSearchListbox configure -state "normal"

            focus $wSearchEntry

        }} $wSearchEntry $wSearchButton $wSearchListbox]

        bind $wSearchEntry <Return> [list apply {{ wSearchButton } {

            $wSearchButton invoke

        }} $wSearchButton]

        set procUpdateLocationCurrent [list apply {{ varLocationCurrent wLocationCurrent } {

            set text [set textVisible [set $varLocationCurrent]]
            set font [$wLocationCurrent cget -font]
            set widthWidget [winfo width $wLocationCurrent]

            while { [font measure $font $textVisible] >= $widthWidget } {
                set textVisible [string range $textVisible 0 end-1]
            }

            if { $text ne $textVisible } {

                set widthWidget [expr { $widthWidget - [font measure $font "... "] }]
                while { [font measure $font $textVisible] >= $widthWidget } {
                    set textVisible [string range $textVisible 0 end-1]
                }

                append textVisible "..."

            }

            $wLocationCurrent configure -text $textVisible

        }} $varLocationCurrent $wLocationCurrent]

        bind $wSearchListbox <<ListboxSelect>> [list apply {{ wSearchListbox varLocationCurrent procUpdateLocationCurrent } {

            if { ![llength [set cursel [$wSearchListbox curselection]]] } {
                return
            }

            set cursel [lindex $cursel 0]
            set cursel [$wSearchListbox get $cursel]
            set $varLocationCurrent $cursel
            {*}$procUpdateLocationCurrent

        }} $wSearchListbox $varLocationCurrent $procUpdateLocationCurrent]

        set procUpdateVisForecast [list apply {{
            varVisibleForecast
            wVisForecastDays wVisForecastIcons wVisForecastTemp
        } {

            if { [set $varVisibleForecast] } {
                $wVisForecastDays  state "!disabled"
                $wVisForecastIcons state "!disabled"
                $wVisForecastTemp  state "!disabled"
            } else {
                $wVisForecastDays  state "disabled"
                $wVisForecastIcons state "disabled"
                $wVisForecastTemp  state "disabled"
            }

        }} $varVisibleForecast \
            $wVisForecastDays $wVisForecastIcons $wVisForecastTemp \
        ]

        $wVisForecast configure -command $procUpdateVisForecast

        set procAction [list apply {{
            varLocationType varLocationCurrent
            varParamTempUnits
            varVisibleLocation varVisibleUpdate varVisibleForecast
            varVisibleForecastDays varVisibleForecastIcons varVisibleForecastTemp
            window action
        } {

            if { $action in {ok apply} } {

                set ::gLocationType    [set $varLocationType]
                set ::gLocationCurrent [set $varLocationCurrent]

                set ::gParamTempUnits [set $varParamTempUnits]

                set ::gVisibleLocation      [set $varVisibleLocation]
                set ::gVisibleUpdate        [set $varVisibleUpdate]
                set ::gVisibleForecast      [set $varVisibleForecast]
                set ::gVisibleForecastDays  [set $varVisibleForecastDays]
                set ::gVisibleForecastIcons [set $varVisibleForecastIcons]
                set ::gVisibleForecastTemp  [set $varVisibleForecastTemp]

            }

            if { $action in {ok close} } {
                destroy $window
            }

        }} $varLocationType $varLocationCurrent \
            $varParamTempUnits \
            $varVisibleLocation $varVisibleUpdate $varVisibleForecast \
            $varVisibleForecastDays $varVisibleForecastIcons $varVisibleForecastTemp \
            [tkm::parent] \
        ]

        $wActionOk configure    -command [concat $procAction ok]
        $wActionClose configure -command [concat $procAction close]
        $wActionApply configure -command [concat $procAction apply]

    }

    set $varParamTempUnits $::gParamTempUnits

    set $varVisibleLocation $::gVisibleLocation
    set $varVisibleUpdate   $::gVisibleUpdate
    set $varVisibleForecast $::gVisibleForecast
    set $varVisibleForecastDays  $::gVisibleForecastDays
    set $varVisibleForecastIcons $::gVisibleForecastIcons
    set $varVisibleForecastTemp  $::gVisibleForecastTemp

    {*}$procUpdateVisForecast

    if { $::gLocationType eq "auto" } {
        $wSearchRadioAuto invoke
    } else {
        $wSearchRadioSpecific invoke
    }

    update

    set $varLocationCurrent $::gLocationCurrent
    {*}$procUpdateLocationCurrent

}

tkm::packer {

    set ::gLocationType "auto"
    set ::gLocationCurrent ""

    set ::gParamTempUnits "C"

    set ::gVisibleLocation 1
    set ::gVisibleUpdate   1
    set ::gVisibleForecast 1
    set ::gVisibleForecastDays  1
    set ::gVisibleForecastIcons 1
    set ::gVisibleForecastTemp  1

    tkm::frame -fill x -pad 5 -- {
        tkm::label -text "Weather settings:" -side left -padx 10 -anchor w
        tkm::button -text "Open" -image [tkm::icon application_go] \
            -side right -padx {0 10} -anchor e \
            -command openSettingsWeather
    }

}
