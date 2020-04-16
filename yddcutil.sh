#!/bin/bash

# yddcutil

# Version:    0.1.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/yddcutil
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

function display_selection() {

	unset i2clists
	unset BUS
	step=display_selection
	MONITORS="$(ddcutil --async detect | grep -Ev "Display |EDID synopsis:|Manufacture year:|EDID version:|VCP version:")"
	DETECT="$(echo "${MONITORS}" | grep "I2C bus:" | awk -F'i2c-' '{print $2}')"
	for i2clist in ${DETECT}; do
		i2clists="${i2clists}${i2clist}!"
	done
	i2clists="$(echo "${i2clists}" | rev | cut -c 2- | rev)"

	INIZIALIZE="$(yad ${YCOMMOPT} --window-icon "monitor" --image "monitor" --title="Display Selection" --text="Please select a Display:
$( echo "${MONITORS}")" --buttons-layout=center --form --field="i2c:CB" "$i2clists" --field="sleep multiplier:NUM" "${SLEEPMULTIPLIER}"!0.000..10!0.050!3 --field="max retries:NUM" "${MAX_RETRIES}"!3..20!1!0 --button="Start"!forward:0 \
--button="Help"!help-about-symbolic:97 \
--button="Exit"!exit:99)"
	display_choice="${?}"
	BUS="$(echo "${INIZIALIZE}" | awk -F'|' '{print $1}')"
	SLEEPMULTIPLIER="$(echo "${INIZIALIZE}" | awk -F'|' '{print $2}' | tr , .)"
	if echo "${SLEEPMULTIPLIER}" | grep -xq "0.000"; then
		SLEEPMULTIPLIER=0.001
	fi
	if echo "${SLEEPMULTIPLIER}" | grep -Eq '^[[:digit:]]*.?[[:digit:]]+$'; then
		true
	else
		echo -e "\e[1;33mwarning: invalid or empty sleep-multiplier. Set to "${SLEEPMULTIPLIER_DEFAULT}"\e[0m"
		SLEEPMULTIPLIER="${SLEEPMULTIPLIER_DEFAULT}"
	fi
	MAX_RETRIES="$(echo "${INIZIALIZE}" | awk -F'|' '{print $3}')"
	if echo "${MAX_RETRIES}" | grep -Eq '^[[:digit:]]+$'; then
		true
	else
		echo -e "\e[1;33mwarning: invalid or empty max-retries. Set to "${MAX_RETRIES_DEFAULT}"\e[0m"
		MAX_RETRIES="${MAX_RETRIES_DEFAULT}"
	fi
	if echo "${BUS}" | grep -Poq '\d+'; then
		if [ -z "${BUS}" ]; then
			display_selection
		else
			load_menu_items
		fi
	elif [ "${display_choice}" -eq 97 ]; then
		yddutil_help
	elif [ "${display_choice}" -eq 99 ]; then
		exit 0
	else
		exit 0
	fi
}

function load_menu_items() {

	CAPABILITIES="$(ddcutil capabilities --sleep-multiplier="${SLEEPMULTIPLIER}" --bus="${BUS}" --nodetect --verbose)"
	if echo "${CAPABILITIES}" | grep -iq "Feature: 10"; then
		true
	else
		no_monitor
	fi
	MODEL="$(echo "${CAPABILITIES}" | grep "model" | awk -F'model' '{print $2}' | awk -F'cmds' '{print $1}') on bus "${BUS}""
	##### MAIN MENU
	# IMAGE
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: DC|Feature: 10|Feature: 12|Feature: 14|Feature: 16|Feature: 18|Feature: 1A'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Image!gnome-colors!Image:1 '
		##### IMAGE MENU
		# Color Presets
		if echo "${CAPABILITIES}" | grep -iq 'Feature: DC'; then
			IMAGEBUTTONS="${IMAGEBUTTONS}"'--button=Presets!gnome-colors!Presets:1 '
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '00'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Standard!monitor!Standard:1 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '01'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Productivity!gnome-colors!Productivity:2 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '02'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Mixed!gnome-colors!Mixed:3 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '03'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Movie!video-television!Movie:4 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '04'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=User!avatar-default!User:5 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '05'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Games!input-gaming-symbolic!Games:6 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '06'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Sports!gnome-colors!Sports:7 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '07'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Professional!gnome-colors!Professional:8 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '08'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=StandardLowPower!monitor!StandardLowPower:9 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '09'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=StandardIntermPower!monitor!StandardIntermPower:10 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0a'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=Demonstration!gnome-colors!Demonstration:11 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: DC' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq 'f0'; then
				PRESETSBUTTONS="${PRESETSBUTTONS}"'--button=DynamicContrast!gnome-colors!DynamicContrast:12 '
			fi
		fi
		# Brightness
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 10'; then
			IMAGEBUTTONS="${IMAGEBUTTONS}"'--button=Brightness!notification-display-brightness-full!Brightness:2 '
		fi
		# Contrast
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 12'; then
			IMAGEBUTTONS="${IMAGEBUTTONS}"'--button=Contrast!notification-display-brightness-full!Contrast:3 '
		fi
		# Temperature
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 14'; then
			IMAGEBUTTONS="${IMAGEBUTTONS}"'--button=Temperature!gnome-colors!Temperature:4 '
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '01'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=sRGB!gnome-colors!sRGB:1 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '02'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=Native!gnome-colors!Native:2 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '03'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=4000K!gnome-colors!4000K:3 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '04'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=5000K!gnome-colors!5000K:4 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '05'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=6500K!gnome-colors!6500K:5 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '06'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=7500K!gnome-colors!7500K:6 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '07'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=8200K!gnome-colors!8200K:7 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '08'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=9300K!gnome-colors!9300K:8 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '09'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=5000K!gnome-colors!5000K:9 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0a'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=10000K!gnome-colors!10000K:10 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0b'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=User1!gnome-colors!User1:11 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0c'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=User2!gnome-colors!User2:12 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: 14' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0d'; then
				TEMPERATUREBUTTONS="${TEMPERATUREBUTTONS}"'--button=User3!gnome-colors!User3:13 '
			fi
		fi
		# Video gain: Red
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 16'; then
			REDGAINBUTTON='--button=Red!gnome-colors!Red:1 '
		fi
		# Video gain: Green
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 18'; then
			GREENGAINBUTTON='--button=Green!gnome-colors!Green:2 '
		fi
		# Video gain: Blue
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 1A'; then
			BLUEGAINBUTTON='--button=Blue!gnome-colors!Blue:3 '
		fi
		# Auto color setup
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 1F'; then
			IMAGEBUTTONS="${IMAGEBUTTONS}"'--button=Auto!gnome-colors!Auto:5 '
		fi
	fi
	# GEOMETRY
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: 20|Feature: 30|Feature: AA'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Geometry!monitor!Geometry:4 '
		##### GEOMETRY MENU
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 20'; then
			GEOMETRYBUTTONS="${GEOMETRYBUTTONS}"'--button=HorizontalPosition!monitor!HorizontalPosition:1 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 30'; then
			GEOMETRYBUTTONS="${GEOMETRYBUTTONS}"'--button=VerticalPosition!monitor!VerticalPosition:2 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 1E'; then
			GEOMETRYBUTTONS="${GEOMETRYBUTTONS}"'--button=Auto!monitor!Auto:3 '
		fi
	fi
	# INPUT
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: 60'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Input!colorimeter-colorhug-symbolic!Input:2 '
		##### INPUT MENU
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '01'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=VGA-1!colorimeter-colorhug-symbolic!VGA-1:1 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '02'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=VGA-2!colorimeter-colorhug-symbolic!VGA-2:2 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '03'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=DVI-1!colorimeter-colorhug-symbolic!DVI-1:3 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '04'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=DVI-2!colorimeter-colorhug-symbolic!DVI-2:4 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '05'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Composite-Video-1!colorimeter-colorhug-symbolic!Composite-Video-1:5 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '06'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Composite-Video-2!colorimeter-colorhug-symbolic!Composite-Video-2:6 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '07'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=S-Video-1!colorimeter-colorhug-symbolic!S-Video-1:7 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '08'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=S-Video-2!colorimeter-colorhug-symbolic!S-Video-2:8 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '09'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Tuner-1!colorimeter-colorhug-symbolic!Tuner-1:9 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0a'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Tuner-2!colorimeter-colorhug-symbolic!Tuner-2:10 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0b'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Tuner-3!colorimeter-colorhug-symbolic!Tuner-3:11 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0c'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Component-Video-(YPrPb/YCrCb)-1!colorimeter-colorhug-symbolic!Component-Video-(YPrPb/YCrCb)-1:12 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0d'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Component-Video-(YPrPb/YCrCb)-2!colorimeter-colorhug-symbolic!Component-Video-(YPrPb/YCrCb)-2:13 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0e'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=Component-Video-(YPrPb/YCrCb)-3!colorimeter-colorhug-symbolic!Component-Video-(YPrPb/YCrCb)-3:14 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '0f'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=DisplayPort-1!colorimeter-colorhug-symbolic!DisplayPort-1:15 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '10'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=DisplayPort-2!colorimeter-colorhug-symbolic!DisplayPort-2:16 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '11'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=HDMI-1!colorimeter-colorhug-symbolic!HDMI-1:17 '
		fi
		if echo "${CAPABILITIES}" | grep -iA1 'Feature: 60' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '12'; then
			INPUTBUTTONS="${INPUTBUTTONS}"'--button=HDMI-2!colorimeter-colorhug-symbolic!HDMI-2:18 '
		fi
	fi
	# AUDIO
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: 62|Feature: 63|Feature: 64|Feature: 8d|Feature: 91|Feature: 93|Feature: 94'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Audio!stock_volume!Audio:3 '
		##### AUDIO MENU
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 62'; then
			AUDIOBUTTONS=$AUDIOBUTTONS'--button=Volume!stock_volume!Volume:1 '
		fi
	fi
	# POWER
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: D6|Feature: D7'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Power!ac-adapter!Power:5 '
		##### POWER MENU
		# Power mode
		if echo "${CAPABILITIES}" | grep -iq 'Feature: D6'; then
			POWERBUTTONS="${POWERBUTTONS}"'--button=PowerMode!ac-adapter!PowerMode:1 '
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D6' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '01'; then
				POWERMODEBUTTONS="${POWERMODEBUTTONS}"'--button=DPM-On&amp;DPMS-Off!ac-adapter!DPM-On&amp;DPMS-Off:1 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D6' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '02'; then
				POWERMODEBUTTONS="${POWERMODEBUTTONS}"'--button=DPM-Off&amp;DPMS-Standby!ac-adapter!DPM-Off&amp;DPMS-Standby:2 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D6' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '03'; then
				POWERMODEBUTTONS="${POWERMODEBUTTONS}"'--button=DPM-Off&amp;DPMS-Suspend!ac-adapter!DPM-Off&amp;DPMS-Suspend:3 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D6' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '04'; then
				POWERMODEBUTTONS="${POWERMODEBUTTONS}"'--button=DPM-Off&amp;DPMS-Off!ac-adapter!DPM-Off&amp;DPMS-Off:4 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D6' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '05'; then
				POWERMODEBUTTONS="${POWERMODEBUTTONS}"'--button=TurnOff-Now!ac-adapter!TurnOff-Now:5 '
			fi
		fi
		# Auxiliary power output
		if echo "${CAPABILITIES}" | grep -iq 'Feature: D7'; then
			POWERBUTTONS="${POWERBUTTONS}"'--button=Auxiliary!ac-adapter!Auxiliary:2 '
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D7' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '01'; then
				POWERAUXBUTTONS="${POWERAUXBUTTONS}"'--button=Disable!ac-adapter!Disable:1 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: D7' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '02'; then
				POWERAUXBUTTONS="${POWERAUXBUTTONS}"'--button=Enable!ac-adapter!Enable:2 '
			fi
		fi
	fi
	# MISC TODO
	if echo "${CAPABILITIES}" | grep -Eiq 'TODO|TODO'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Misc!applications-engineering!Misc:6 '
		##### MISC MENU
	fi
	# INFO
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: AC|Feature: AE|Feature: 60|Feature: 10|Feature: 12|Feature: 14|Feature: 16|Feature: 18|Feature: 1A|Feature: 62'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Info!stock_dialog-info!Info:7 '
		##### INFO MENU
		# Advanced info
		if echo "${CAPABILITIES}" | grep -Eiq 'Feature: B2|Feature: B6|Feature: C6|Feature: C8|Feature: C9|Feature: DF'; then
			INFOBUTTON='--button=Advanced!forward!Advanced:1 '
		fi
	fi
	# RESET
	if echo "${CAPABILITIES}" | grep -Eiq 'Feature: 04|Feature: 05|Feature: 06|Feature: 08|Feature: 0A|Feature: B0'; then
		MENUBUTTONS="${MENUBUTTONS}"'--button=Reset!view-wrapped-symbolic!Reset:8 '
		##### RESET MENU
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 04'; then
			RESETBUTTONS="${RESETBUTTONS}"'--button=Factory!dialog-warning!Factory:1 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 05'; then
			RESETBUTTONS="${RESETBUTTONS}"'--button=Brightness&amp;Contrast!dialog-warning!Brightness&amp;Contrast:2 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 06'; then
			RESETBUTTONS="${RESETBUTTONS}"'--button=Geometry!dialog-warning!Geometry:3 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 08'; then
			RESETBUTTONS="${RESETBUTTONS}"'--button=Color!dialog-warning!Color:4 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: 0A'; then
			RESETBUTTONS="${RESETBUTTONS}"'--button=TV!dialog-warning!TV:5 '
		fi
		if echo "${CAPABILITIES}" | grep -iq 'Feature: B0'; then
			RESETBUTTONS="${RESETBUTTONS}"'--button=Save&amp;Load!dialog-warning!Save&amp;Load:6 '
			#
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: B0' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '01'; then
				RESETRESTOREBUTTONS="${RESETRESTOREBUTTONS}"'--button=Save!dialog-warning!Save:1 '
			fi
			if echo "${CAPABILITIES}" | grep -iA1 'Feature: B0' | grep 'Values (unparsed):' | awk -F':' '{print $2}' | grep -iq '02'; then
				RESETRESTOREBUTTONS="${RESETRESTOREBUTTONS}"'--button=Load!dialog-warning!Load:2 '
			fi
		fi
	fi
	step=main_menu
	main_menu
}

function main_menu() {

	yad ${YCOMMOPT} --window-icon "monitor" --image "monitor" --title="${VENDOR} ${MODEL}" --text="MENU" ${MENUBUTTONS} --button=Help!help-about-symbolic!Help:97 --button="Display"!monitor!"Display Selection":98 --button=Exit!exit!Exit:99
	main_choice="${?}"
	if [ "${main_choice}" -eq 1 ]; then
		image_menu
	elif [ "${main_choice}" -eq 2 ]; then
		input_menu
	elif [ "${main_choice}" -eq 3 ]; then
		audio_menu
	elif [ "${main_choice}" -eq 4 ]; then
		geometry_menu
	elif [ "${main_choice}" -eq 5 ]; then
		power_menu
	elif [ "${main_choice}" -eq 6 ]; then
		misc_menu
	elif [ "${main_choice}" -eq 7 ]; then
		info_menu
	elif [ "${main_choice}" -eq 8 ]; then
		reset_menu
	elif [ "${main_choice}" -eq 97 ]; then
		yddutil_help
	elif [ "${main_choice}" -eq 98 ]; then
		exec "$yddcutilrestart" "${options}"
	elif [ "${main_choice}" -eq 99 ]; then
		exit 0
	else
		exit 0
	fi
}

function image_menu() {

	yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image" ${IMAGEBUTTONS} --button="Go Back"!back:98
	image_choice="${?}"
	if [ "${image_choice}" -eq 1 ]; then
		presets_menu
	elif [ "${image_choice}" -eq 2 ]; then
		set_brightness
	elif [ "${image_choice}" -eq 3 ]; then
		set_contrast
	elif [ "${image_choice}" -eq 4 ]; then
		set_temperature
	elif [ "${image_choice}" -eq 5 ]; then
		ddcutil_setvcp 1f 03
		image_menu
	elif [ "${image_choice}" -eq 98 ]; then
		main_menu
	else
		exit 0
	fi
}

function presets_menu() {

#	FEATURE="dc"
	while true; do
		PRESET="$(ddcutil_getvcp dc | awk -F': ' '{print $2}' | awk -F'(' '{print $1}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Pesets
Current: $PRESET" $PRESETSBUTTONS --button="Go Back"!back:98
		presets_choice="${?}"
		if [ "${presets_choice}" -eq 1 ]; then
			ddcutil_setvcp dc 00
		elif [ "${presets_choice}" -eq 2 ]; then
			ddcutil_setvcp dc 01
		elif [ "${presets_choice}" -eq 3 ]; then
			ddcutil_setvcp dc 02
		elif [ "${presets_choice}" -eq 4 ]; then
			ddcutil_setvcp dc 03
		elif [ "${presets_choice}" -eq 5 ]; then
			ddcutil_setvcp dc 04
		elif [ "${presets_choice}" -eq 6 ]; then
			ddcutil_setvcp dc 05
		elif [ "${presets_choice}" -eq 7 ]; then
			ddcutil_setvcp dc 06
		elif [ "${presets_choice}" -eq 8 ]; then
			ddcutil_setvcp dc 07
		elif [ "${presets_choice}" -eq 9 ]; then
			ddcutil_setvcp dc 08
		elif [ "${presets_choice}" -eq 10 ]; then
			ddcutil_setvcp dc 09
		elif [ "${presets_choice}" -eq 11 ]; then
			ddcutil_setvcp dc 0a
		elif [ "${presets_choice}" -eq 12 ]; then
			ddcutil_setvcp dc f0
		elif [ "${presets_choice}" -eq 98 ]; then
			image_menu
		else
			exit 0
		fi
	done
}

function set_brightness() {

#	FEATURE="10"
	while true; do
	BRIGHTNESS="$(ddcutil_getvcp 10 | awk -F' ' '{print $4}')"
	yad ${YCOMMOPT} --window-icon "monitor" --image "notification-display-brightness-full" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Brightness
Current: $BRIGHTNESS" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
	brightness_choice="${?}"
	if [ "${brightness_choice}" -eq 0 ]; then
		ddcutil_setvcp 10 0
	elif [ "${brightness_choice}" -eq 1 ]; then
		ddcutil_setvcp 10 10
	elif [ "${brightness_choice}" -eq 2 ]; then
		ddcutil_setvcp 10 20
	elif [ "${brightness_choice}" -eq 3 ]; then
		ddcutil_setvcp 10 30
	elif [ "${brightness_choice}" -eq 4 ]; then
		ddcutil_setvcp 10 40
	elif [ "${brightness_choice}" -eq 5 ]; then
		ddcutil_setvcp 10 50
	elif [ "${brightness_choice}" -eq 6 ]; then
		ddcutil_setvcp 10 60
	elif [ "${brightness_choice}" -eq 7 ]; then
		ddcutil_setvcp 10 70
	elif [ "${brightness_choice}" -eq 8 ]; then
		ddcutil_setvcp 10 80
	elif [ "${brightness_choice}" -eq 9 ]; then
		ddcutil_setvcp 10 90
	elif [ "${brightness_choice}" -eq 10 ]; then
		ddcutil_setvcp 10 100
	elif [ "${brightness_choice}" -eq 11 ]; then
		if [ "${BRIGHTNESS}" = 0 ]; then
			set_brightness
		else
			ddcutil_setvcp 10 "- 1"
		fi
	elif [ "${brightness_choice}" -eq 12 ]; then
		if [ "${BRIGHTNESS}" = 100 ]; then
			set_brightness
		else
			ddcutil_setvcp 10 "+ 1"
		fi
	elif [ "${brightness_choice}" -eq 98 ]; then
		image_menu
	else
		exit 0
	fi
	done
}

function set_contrast() {

	while true; do
	CONTRAST="$(ddcutil_getvcp 12 | awk -F' ' '{print $4}')"
	yad ${YCOMMOPT} --window-icon "monitor" --image "notification-display-brightness-full" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Contrast
Current: $CONTRAST" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
	contrast_choice="${?}"
	if [ "${contrast_choice}" -eq 0 ]; then
		ddcutil_setvcp 12 0
	elif [ "${contrast_choice}" -eq 1 ]; then
		ddcutil_setvcp 12 10
	elif [ "${contrast_choice}" -eq 2 ]; then
		ddcutil_setvcp 12 20
	elif [ "${contrast_choice}" -eq 3 ]; then
		ddcutil_setvcp 12 30
	elif [ "${contrast_choice}" -eq 4 ]; then
		ddcutil_setvcp 12 40
	elif [ "${contrast_choice}" -eq 5 ]; then
		ddcutil_setvcp 12 50
	elif [ "${contrast_choice}" -eq 6 ]; then
		ddcutil_setvcp 12 60
	elif [ "${contrast_choice}" -eq 7 ]; then
		ddcutil_setvcp 12 70
	elif [ "${contrast_choice}" -eq 8 ]; then
		ddcutil_setvcp 12 80
	elif [ "${contrast_choice}" -eq 9 ]; then
		ddcutil_setvcp 12 90
	elif [ "${contrast_choice}" -eq 10 ]; then
		ddcutil_setvcp 12 100
	elif [ "${contrast_choice}" -eq 11 ]; then
		if [ "${CONTRAST}" != 0 ]; then
			ddcutil_setvcp 12 "- 1"
		fi
	elif [ "${contrast_choice}" -eq 12 ]; then
		if [ "${CONTRAST}" != 100 ]; then
			ddcutil_setvcp 12 "+ 1"
		fi
	elif [ "${contrast_choice}" -eq 98 ]; then
		image_menu
	else
		exit 0
	fi
	done
}

function set_temperature() {

	while true; do
		TEMPERATURE="$(ddcutil_getvcp 14 | awk -F' ' '{print $4}')"
		if [ "${TEMPERATURE}" = "x01" ]; then
			TEMPERATURE="sRGB"
		elif [ "${TEMPERATURE}" = "x02" ]; then
			TEMPERATURE="Native"
		elif [ "${TEMPERATURE}" = "x03" ]; then
			TEMPERATURE="4000 K"
		elif [ "${TEMPERATURE}" = "x04" ]; then
			TEMPERATURE="5000 K"
		elif [ "${TEMPERATURE}" = "x05" ]; then
			TEMPERATURE="6500 K"
		elif [ "${TEMPERATURE}" = "x06" ]; then
			TEMPERATURE="7500 K"
		elif [ "${TEMPERATURE}" = "x07" ]; then
			TEMPERATURE="8200 K"
		elif [ "${TEMPERATURE}" = "x08" ]; then
			TEMPERATURE="9300 K"
		elif [ "${TEMPERATURE}" = "x09" ]; then
			TEMPERATURE="10000 K"
		elif [ "${TEMPERATURE}" = "x0a" ]; then
			TEMPERATURE="11500 K"
		elif [ "${TEMPERATURE}" = "x0b" ]; then
			TEMPERATURE="User 1"
		elif [ "${TEMPERATURE}" = "x0c" ]; then
			TEMPERATURE="User 2"
		elif [ "${TEMPERATURE}" = "x0d" ]; then
			TEMPERATURE="User 3"
		fi
		yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Temperature
Current: $TEMPERATURE" $TEMPERATUREBUTTONS --button="Go Back"!back:98
		temperature_choice="${?}"
		if [ "${temperature_choice}" -eq 1 ]; then
			if [ "${TEMPERATURE}" = "sRGB" ]; then
				set_temperature
			else
				VALUE="0x01"
			fi
		elif [ "${temperature_choice}" -eq 2 ]; then
			if [ "${TEMPERATURE}" != "Native" ]; then
				ddcutil_setvcp 14 0x02
			fi
		elif [ "${temperature_choice}" -eq 3 ]; then
			if [ "${TEMPERATURE}" != "4000 K" ]; then
				ddcutil_setvcp 14 0x03
			fi
		elif [ "${temperature_choice}" -eq 4 ]; then
			if [ "${TEMPERATURE}" != "5000 K" ]; then
				ddcutil_setvcp 14 0x04
			fi
		elif [ "${temperature_choice}" -eq 5 ]; then
			if [ "${TEMPERATURE}" != "6500 K" ]; then
				ddcutil_setvcp 14 0x05
			fi
		elif [ "${temperature_choice}" -eq 6 ]; then
			if [ "${TEMPERATURE}" != "7500 K" ]; then
				ddcutil_setvcp 14 0x06
			fi
		elif [ "${temperature_choice}" -eq 7 ]; then
			if [ "${TEMPERATURE}" != "8200 K" ]; then
				ddcutil_setvcp 14 0x07
			fi
		elif [ "${temperature_choice}" -eq 8 ]; then
			if [ "${TEMPERATURE}" != "9300 K" ]; then
				ddcutil_setvcp 14 0x08
			fi
		elif [ "${temperature_choice}" -eq 9 ]; then
			if [ "${TEMPERATURE}" != "10000 K" ]; then
				ddcutil_setvcp 14 0x09
			fi
		elif [ "${temperature_choice}" -eq 10 ]; then
			if [ "${TEMPERATURE}" != "11500 K" ]; then
				ddcutil_setvcp 14 0x0a
			fi
		elif [ "${temperature_choice}" -eq 11 ]; then
			ddcutil_setvcp 14 0x0b
			color_menu
		elif [ "${temperature_choice}" -eq 12 ]; then
			ddcutil_setvcp 14 0x0c
			color_menu
		elif [ "${temperature_choice}" -eq 13 ]; then
			ddcutil_setvcp 14 0x0d
			color_menu
		elif [ "${temperature_choice}" -eq 98 ]; then
			image_menu
		else
			exit 0
		fi
	done
}

function color_menu() {

	yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Temperature > User" ${REDGAINBUTTON}  ${GREENGAINBUTTON}  ${BLUEGAINBUTTON} --button="Go Back"!back:98
	color_choice="${?}"
	if [ "${color_choice}" -eq 1 ]; then
		color_user_red
	elif [ "${color_choice}" -eq 2 ]; then
		color_user_green
	elif [ "${color_choice}" -eq 3 ]; then
		color_user_blue
	elif [ "${color_choice}" -eq 98 ]; then
		set_temperature
	else
		exit 0
	fi
}

function color_user_red() {

	while true; do
		REDGAIN="$(ddcutil_getvcp 16 | awk -F' ' '{print $4}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Temperature > User > Red
Current: $REDGAIN" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
		redgain_choice="${?}"
		if [ "${redgain_choice}" -eq 0 ]; then
			ddcutil_setvcp 16 0
		elif [ "${redgain_choice}" -eq 1 ]; then
			ddcutil_setvcp 16 10
		elif [ "${redgain_choice}" -eq 2 ]; then
			ddcutil_setvcp 16 20
		elif [ "${redgain_choice}" -eq 3 ]; then
			ddcutil_setvcp 16 30
		elif [ "${redgain_choice}" -eq 4 ]; then
			ddcutil_setvcp 16 40
		elif [ "${redgain_choice}" -eq 5 ]; then
			ddcutil_setvcp 16 50
		elif [ "${redgain_choice}" -eq 6 ]; then
			ddcutil_setvcp 16 60
		elif [ "${redgain_choice}" -eq 7 ]; then
			ddcutil_setvcp 16 70
		elif [ "${redgain_choice}" -eq 8 ]; then
			ddcutil_setvcp 16 80
		elif [ "${redgain_choice}" -eq 9 ]; then
			ddcutil_setvcp 16 90
		elif [ "${redgain_choice}" -eq 10 ]; then
			ddcutil_setvcp 16 100
		elif [ "${redgain_choice}" -eq 11 ]; then
			ddcutil_setvcp 16 "- 1"
		elif [ "${redgain_choice}" -eq 12 ]; then
			ddcutil_setvcp 16 "+ 1"
		elif [ "${redgain_choice}" -eq 98 ]; then
			color_menu
		else
			exit 0
		fi
	done
}

function color_user_green() {

	while true; do
		GREENGAIN="$(ddcutil_getvcp 18 | awk -F' ' '{print $4}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Temperature > User > Green
Current: $GREENGAIN" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
		greengain_choice="${?}"
		if [ "${greengain_choice}" -eq 0 ]; then
			ddcutil_setvcp 18 0
		elif [ "${greengain_choice}" -eq 1 ]; then
			ddcutil_setvcp 18 10
		elif [ "${greengain_choice}" -eq 2 ]; then
			ddcutil_setvcp 18 20
		elif [ "${greengain_choice}" -eq 3 ]; then
			ddcutil_setvcp 18 30
		elif [ "${greengain_choice}" -eq 4 ]; then
			ddcutil_setvcp 18 40
		elif [ "${greengain_choice}" -eq 5 ]; then
			ddcutil_setvcp 18 50
		elif [ "${greengain_choice}" -eq 6 ]; then
			ddcutil_setvcp 18 60
		elif [ "${greengain_choice}" -eq 7 ]; then
			ddcutil_setvcp 18 70
		elif [ "${greengain_choice}" -eq 8 ]; then
			ddcutil_setvcp 18 80
		elif [ "${greengain_choice}" -eq 9 ]; then
			ddcutil_setvcp 18 90
		elif [ "${greengain_choice}" -eq 10 ]; then
			ddcutil_setvcp 18 100
		elif [ "${greengain_choice}" -eq 11 ]; then
			ddcutil_setvcp 18 "- 1"
		elif [ "${greengain_choice}" -eq 12 ]; then
			ddcutil_setvcp 18 "+ 1"
		elif [ "${greengain_choice}" -eq 98 ]; then
			color_menu
		else
			exit 0
		fi
	done
}

function color_user_blue() {

	while true; do
		BLUEGAIN="$(ddcutil_getvcp 1a | awk -F' ' '{print $4}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Image > Temperature > User > Blue
Current: $BLUEGAIN" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
		bluegain_choice="${?}"
		if [ "${bluegain_choice}" -eq 0 ]; then
			ddcutil_setvcp 1a 0
		elif [ "${bluegain_choice}" -eq 1 ]; then
			ddcutil_setvcp 1a 10
		elif [ "${bluegain_choice}" -eq 2 ]; then
			ddcutil_setvcp 1a 20
		elif [ "${bluegain_choice}" -eq 3 ]; then
			ddcutil_setvcp 1a 30
		elif [ "${bluegain_choice}" -eq 4 ]; then
			ddcutil_setvcp 1a 40
		elif [ "${bluegain_choice}" -eq 5 ]; then
			ddcutil_setvcp 1a 50
		elif [ "${bluegain_choice}" -eq 6 ]; then
			ddcutil_setvcp 1a 60
		elif [ "${bluegain_choice}" -eq 7 ]; then
			ddcutil_setvcp 1a 70
		elif [ "${bluegain_choice}" -eq 8 ]; then
			ddcutil_setvcp 1a 80
		elif [ "${bluegain_choice}" -eq 9 ]; then
			ddcutil_setvcp 1a 90
		elif [ "${bluegain_choice}" -eq 10 ]; then
			ddcutil_setvcp 1a 100
		elif [ "${bluegain_choice}" -eq 11 ]; then
			ddcutil_setvcp 1a "- 1"
		elif [ "${bluegain_choice}" -eq 12 ]; then
			ddcutil_setvcp 1a "+ 1"
		elif [ "${bluegain_choice}" -eq 98 ]; then
			color_menu
		else
			exit 0
		fi
	done
}

function geometry_menu() {

	yad ${YCOMMOPT} --window-icon "monitor" --image "monitor" --title="${VENDOR} ${MODEL}" --text="MENU > Geometry" ${GEOMETRYBUTTONS} --button="Go Back"!back:98
	color_choice="${?}"
	if [ "${color_choice}" -eq 1 ]; then
		geometry_horizontal_position
	elif [ "${color_choice}" -eq 2 ]; then
		geometry_vertical_position
	elif [ "${color_choice}" -eq 3 ]; then
		ddcutil_setvcp 1e 03
		geometry_menu
	elif [ "${color_choice}" -eq 98 ]; then
		main_menu
	else
		exit 0
	fi
}

function geometry_horizontal_position() {

	while true; do
		HORIZONTAL="$(ddcutil_getvcp 20 | awk -F' ' '{print $4}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "gnome-colors" --title="${VENDOR} ${MODEL}" --text="MENU > Geometry > Horizontal Position
Current: $HORIZONTAL" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
		horizontal_choice="${?}"
		if [ "${horizontal_choice}" -eq 0 ]; then
			ddcutil_setvcp 20 0
		elif [ "${horizontal_choice}" -eq 1 ]; then
			ddcutil_setvcp 20 10
		elif [ "${horizontal_choice}" -eq 2 ]; then
			ddcutil_setvcp 20 20
		elif [ "${horizontal_choice}" -eq 3 ]; then
			ddcutil_setvcp 20 30
		elif [ "${horizontal_choice}" -eq 4 ]; then
			ddcutil_setvcp 20 40
		elif [ "${horizontal_choice}" -eq 5 ]; then
			ddcutil_setvcp 20 50
		elif [ "${horizontal_choice}" -eq 6 ]; then
			ddcutil_setvcp 20 60
		elif [ "${horizontal_choice}" -eq 7 ]; then
			ddcutil_setvcp 20 70
		elif [ "${horizontal_choice}" -eq 8 ]; then
			ddcutil_setvcp 20 80
		elif [ "${horizontal_choice}" -eq 9 ]; then
			ddcutil_setvcp 20 90
		elif [ "${horizontal_choice}" -eq 10 ]; then
			ddcutil_setvcp 20 100
		elif [ "${horizontal_choice}" -eq 11 ]; then
			ddcutil_setvcp 20 "- 1"
		elif [ "${horizontal_choice}" -eq 12 ]; then
			ddcutil_setvcp 20 "+ 1"
		elif [ "${horizontal_choice}" -eq 98 ]; then
			geometry_menu
		else
			exit 0
		fi
	done
}

function geometry_vertical_position() {

	while true; do
		VERTICAL="$(ddcutil_getvcp 30 | awk -F' ' '{print $4}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "monitor" --title="${VENDOR} ${MODEL}" --text="MENU > Geometry > Vertical Position
Current: $VERTICAL" \
--button=0:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
		vertical_choice="${?}"
		if [ "${vertical_choice}" -eq 0 ]; then
			ddcutil_setvcp 30 0
		elif [ "${vertical_choice}" -eq 1 ]; then
			ddcutil_setvcp 30 10
		elif [ "${vertical_choice}" -eq 2 ]; then
			ddcutil_setvcp 30 20
		elif [ "${vertical_choice}" -eq 3 ]; then
			ddcutil_setvcp 30 30
		elif [ "${vertical_choice}" -eq 4 ]; then
			ddcutil_setvcp 30 40
		elif [ "${vertical_choice}" -eq 5 ]; then
			ddcutil_setvcp 30 50
		elif [ "${vertical_choice}" -eq 6 ]; then
			ddcutil_setvcp 30 60
		elif [ "${vertical_choice}" -eq 7 ]; then
			ddcutil_setvcp 30 70
		elif [ "${vertical_choice}" -eq 8 ]; then
			ddcutil_setvcp 30 80
		elif [ "${vertical_choice}" -eq 9 ]; then
			ddcutil_setvcp 30 90
		elif [ "${vertical_choice}" -eq 10 ]; then
			ddcutil_setvcp 30 100
		elif [ "${vertical_choice}" -eq 11 ]; then
			ddcutil_setvcp 30 "- 1"
		elif [ "${vertical_choice}" -eq 12 ]; then
			ddcutil_setvcp 30 "+ 1"
		elif [ "${vertical_choice}" -eq 98 ]; then
			geometry_menu
		else
			exit 0
		fi
	done
}

function input_menu() {

	while true ; do
		INPUT="$(ddcutil_getvcp 60 | awk -F': ' '{print $2}' | awk -F'(' '{print $1}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "colorimeter-colorhug-symbolic" --title="${VENDOR} ${MODEL}" --text="MENU > Input Source
Current: $INPUT" ${INPUTBUTTONS} --button="Go Back"!back:98
		input_choice="${?}"
		if [ "${input_choice}" -eq 1 ]; then
			ddcutil_setvcp 60 01
		elif [ "${input_choice}" -eq 2 ]; then
			ddcutil_setvcp 60 02
		elif [ "${input_choice}" -eq 3 ]; then
			ddcutil_setvcp 60 03
		elif [ "${input_choice}" -eq 4 ]; then
			ddcutil_setvcp 60 04
		elif [ "${input_choice}" -eq 5 ]; then
			ddcutil_setvcp 60 05
		elif [ "${input_choice}" -eq 6 ]; then
			ddcutil_setvcp 60 06
		elif [ "${input_choice}" -eq 7 ]; then
			ddcutil_setvcp 60 07
		elif [ "${input_choice}" -eq 8 ]; then
			ddcutil_setvcp 60 08
		elif [ "${input_choice}" -eq 9 ]; then
			ddcutil_setvcp 60 09
		elif [ "${input_choice}" -eq 10 ]; then
			ddcutil_setvcp 60 0a
		elif [ "${input_choice}" -eq 11 ]; then
			ddcutil_setvcp 60 0b
		elif [ "${input_choice}" -eq 12 ]; then
			ddcutil_setvcp 60 0c
		elif [ "${input_choice}" -eq 13 ]; then
			ddcutil_setvcp 60 0d
		elif [ "${input_choice}" -eq 14 ]; then
			ddcutil_setvcp 60 0e
		elif [ "${input_choice}" -eq 15 ]; then
			ddcutil_setvcp 60 0f
		elif [ "${input_choice}" -eq 16 ]; then
			ddcutil_setvcp 60 10
		elif [ "${input_choice}" -eq 17 ]; then
			ddcutil_setvcp 60 11
		elif [ "${input_choice}" -eq 18 ]; then
			ddcutil_setvcp 60 12
		elif [ "${input_choice}" -eq 98 ]; then
			main_menu
		else
			exit 0
		fi
	done
}

function audio_menu() {

	yad ${YCOMMOPT} --window-icon "monitor" --image "stock_volume" --title="${VENDOR} ${MODEL}" --text="MENU > Audio" ${AUDIOBUTTONS} --button="Go Back"!back:98
	audio_choice="${?}"
	if [ "${audio_choice}" -eq 1 ]; then
		audio_volume
	elif [ "${audio_choice}" -eq 98 ]; then
		main_menu
	else
		exit 0
	fi
}

function audio_volume() {

	while true; do
		VOLUME="$(ddcutil_getvcp 62 | awk -F' ' '{print $4}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "stock_volume" --title="${VENDOR} ${MODEL}" --text="MENU > Audio > Audio Speaker Volume
Current: $VOLUME" \
--button=Mute:0 \
--button=10:1 \
--button=20:2 \
--button=30:3 \
--button=40:4 \
--button=50:5 \
--button=60:6 \
--button=70:7 \
--button=80:8 \
--button=90:9 \
--button=100:10 \
--button=-:11 \
--button=+:12 \
--button="Go Back"!back:98
		volume_choice="${?}"
		if [ "${volume_choice}" -eq 0 ]; then
			ddcutil_setvcp 62 0
		elif [ "${volume_choice}" -eq 1 ]; then
			ddcutil_setvcp 62 10
		elif [ "${volume_choice}" -eq 2 ]; then
			ddcutil_setvcp 62 20
		elif [ "${volume_choice}" -eq 3 ]; then
			ddcutil_setvcp 62 30
		elif [ "${volume_choice}" -eq 4 ]; then
			ddcutil_setvcp 62 40
		elif [ "${volume_choice}" -eq 5 ]; then
			ddcutil_setvcp 62 50
		elif [ "${volume_choice}" -eq 6 ]; then
			ddcutil_setvcp 62 60
		elif [ "${volume_choice}" -eq 7 ]; then
			ddcutil_setvcp 62 70
		elif [ "${volume_choice}" -eq 8 ]; then
			ddcutil_setvcp 62 80
		elif [ "${volume_choice}" -eq 9 ]; then
			ddcutil_setvcp 62 90
		elif [ "${volume_choice}" -eq 10 ]; then
			ddcutil_setvcp 62 100
		elif [ "${volume_choice}" -eq 11 ]; then
			ddcutil_setvcp 62 "- 1"
		elif [ "${volume_choice}" -eq 12 ]; then
			ddcutil_setvcp 62 "+ 1"
		elif [ "${volume_choice}" -eq 98 ]; then
			audio_menu
		else
			exit 0
		fi
	done
}

function power_menu() {

	yad ${YCOMMOPT} --window-icon "monitor" --image "ac-adapter" --title="${VENDOR} ${MODEL}" --text="MENU > Power" ${POWERBUTTONS} --button="Go Back"!back:98
	power_choice="${?}"
	if [ "${power_choice}" -eq 1 ]; then
		power_mode_menu
	elif [ "${power_choice}" -eq 2 ]; then
		power_auxiliary_menu
	elif [ "${power_choice}" -eq 98 ]; then
		main_menu
	else
		exit 0
	fi
}

function power_mode_menu() {

	while true; do
		POWERMODE="$(ddcutil_getvcp d6 | awk -F'): ' '{print $2}' | awk -F'(' '{print $1}')"
		yad ${YCOMMOPT} --window-icon "monitor" --image "ac-adapter" --title="${VENDOR} ${MODEL}" --text="MENU > Power > Power mode
Current: $POWERMODE" ${POWERMODEBUTTONS} --button="Go Back"!back:98
		power_mode_choice="${?}"
		if [ "${power_mode_choice}" -eq 1 ]; then
			ddcutil_setvcp d6 01
		elif [ "${power_mode_choice}" -eq 2 ]; then
			ddcutil_setvcp d6 02
		elif [ "${power_mode_choice}" -eq 3 ]; then
			ddcutil_setvcp d6 03
		elif [ "${power_mode_choice}" -eq 4 ]; then
			ddcutil_setvcp d6 04
		elif [ "${power_mode_choice}" -eq 5 ]; then
			ddcutil_setvcp d6 05
		elif [ "${power_mode_choice}" -eq 98 ]; then
			power_menu
		else
			exit 0
		fi
	done
}

function power_auxiliary_menu() {

	while true; do
		yad ${YCOMMOPT} --window-icon "monitor" --image "ac-adapter" --title="${VENDOR} ${MODEL}" --text="MENU > Power > Auxiliary power output" ${POWERMODEBUTTONS} --button="Go Back"!back:98
		power_auxiliary_choice="${?}"
		if [ "${power_auxiliary_choice}" -eq 1 ]; then
			ddcutil_setvcp d7 01
		elif [ "${power_auxiliary_choice}" -eq 2 ]; then
			ddcutil_setvcp d7 02
		elif [ "${power_mode_choice}" -eq 98 ]; then
			power_menu
		else
			exit 0
		fi
	done
}

function misc_menu() {

	echo -n
}

function info_menu() {

	HORIZONTALFREQ="Horizontal Frequency: $(ddcutil_getvcp ac | awk -F': ' '{print $2}')"
	VERTICALFREQ="Vertical Frequency: $(ddcutil_getvcp ae | awk -F': ' '{print $2}')"
	INPUT="Input Source: $(ddcutil_getvcp 60 | awk -F': ' '{print $2}' | awk -F'(' '{print $1}')"
	BRIGHTNESS="Brightness: $(ddcutil_getvcp 10 | awk -F' ' '{print $4}')"
	CONTRAST="Contrast: $(ddcutil_getvcp 12 | awk -F' ' '{print $4}')"
	TEMPERATURE="$(ddcutil_getvcp 14 | awk -F' ' '{print $4}')"
	if [ "${TEMPERATURE}" = "x01" ]; then
		TEMPERATURE="Temperature: sRGB"
	elif [ "${TEMPERATURE}" = "x02" ]; then
		TEMPERATURE="Temperature: Native"
	elif [ "${TEMPERATURE}" = "x03" ]; then
		TEMPERATURE="Temperature: 4000 K"
	elif [ "${TEMPERATURE}" = "x04" ]; then
		TEMPERATURE="Temperature: 5000 K"
	elif [ "${TEMPERATURE}" = "x05" ]; then
		TEMPERATURE="Temperature: 6500 K"
	elif [ "${TEMPERATURE}" = "x06" ]; then
		TEMPERATURE="Temperature: 7500 K"
	elif [ "${TEMPERATURE}" = "x07" ]; then
		TEMPERATURE="Temperature: 8200 K"
	elif [ "${TEMPERATURE}" = "x08" ]; then
		TEMPERATURE="Temperature: 9300 K"
	elif [ "${TEMPERATURE}" = "x09" ]; then
		TEMPERATURE="Temperature: 10000 K"
	elif [ "${TEMPERATURE}" = "x0a" ]; then
		TEMPERATURE="Temperature: 11500 K"
	elif [ "${TEMPERATURE}" = "x0b" ]; then
		TEMPERATURE="Temperature: User 1"
	elif [ "${TEMPERATURE}" = "x0c" ]; then
		TEMPERATURE="Temperature: User 2"
	elif [ "${TEMPERATURE}" = "x0d" ]; then
		TEMPERATURE="Temperature: User 3"
	fi
	REDGAIN=" - Red Gain: $(ddcutil_getvcp 16 | awk -F' ' '{print $4}')"
	GREENGAIN=" - Green Gain: $(ddcutil_getvcp 18 | awk -F' ' '{print $4}')"
	BLUEGAIN=" - Blue Gain: $(ddcutil_getvcp 1a | awk -F' ' '{print $4}')"
	VOLUME="Speaker Volume: $(ddcutil_getvcp 62 | awk -F' ' '{print $4}')"
	INFO="Resolution:
$HORIZONTALFREQ
$VERTICALFREQ
$INPUT
$BRIGHTNESS
$CONTRAST
$TEMPERATURE
$REDGAIN
$GREENGAIN
$BLUEGAIN
$VOLUME"
	echo "$INFO" | \
	yad ${YCOMMOPT} --window-icon "monitor" --image "stock_dialog-info" --title="${VENDOR} ${MODEL}" --text="MENU > Info" --width=1024 --height=500 --text-info ${INFOBUTTON} --button="Go Back"!back:98
	info_choice="${?}"
	if [ "${info_choice}" -eq 1 ]; then
		info_advanced_menu
	elif [ "${info_choice}" -eq 98 ]; then
		main_menu
	else
		exit 0
	fi
}

function info_advanced_menu() {

	SERIAL="Serial Number: $(ddcutil --sleep-multiplier="${SLEEPMULTIPLIER}" --async detect | grep /dev/i2c-$BUS -A 4 | grep -Po '(?<=Serial number: ).*')"
	FPSBL="Flat Panel Sub-Pixel Layout: $(ddcutil_getvcp b2 | awk -F': ' '{print $2}')"
	DTT="Display Technology Type: $(ddcutil_getvcp b6 | awk -F': ' '{print $2}')"
	AEK="Application Enable Key: $(ddcutil_getvcp c6 | awk -F': ' '{print $2}')"
	DCT="Display Controller Type: $(ddcutil_getvcp c8 | awk -F'): ' '{print $2}')"
	FIRMWARE="Display Firmware Level: $(ddcutil_getvcp c9 | awk -F'): ' '{print $2}')"
	VCP="VCP Version: $(ddcutil_getvcp df | awk -F'): ' '{print $2}')"
	INFOADVANCED="$SERIAL
$FPSBL
$DTT
$AEK
$DCT
$FIRMWARE
$VCP"
	echo "$INFOADVANCED" | \
	yad ${YCOMMOPT} --window-icon "monitor" --image "stock_dialog-info" --title="${VENDOR} ${MODEL}" --text="MENU > Info > Advanced" --width=1200 --height=500 --text-info \
--buttons-layout=spread \
--button="Go Back"!back:98
	info_advanced_choice="${?}"
	if [ "${info_advanced_choice}" -eq 98 ]; then
		info_menu
	else
		exit 0
	fi
}

function reset_menu() {

	while true; do
		yad ${YCOMMOPT} --window-icon "monitor" --image "view-wrapped-symbolic" --title="${VENDOR} ${MODEL}" --text="MENU > Reset" ${RESETBUTTONS} --button="Go Back"!back:98
		reset_choice="${?}"
		if [ "${reset_choice}" -eq 1 ]; then
			ddcutil_setvcp 04 03
		elif [ "${reset_choice}" -eq 2 ]; then
			ddcutil_setvcp 05 03
		elif [ "${reset_choice}" -eq 3 ]; then
			ddcutil_setvcp 06 03
		elif [ "${reset_choice}" -eq 4 ]; then
			ddcutil_setvcp 08 03
		elif [ "${reset_choice}" -eq 5 ]; then
			ddcutil_setvcp 0a 03
		elif [ "${reset_choice}" -eq 6 ]; then
			reset_restore_menu
		elif [ "${reset_choice}" -eq 98 ]; then
			main_menu
		else
			exit 0
		fi
	done
}

function reset_restore_menu() {

	FEATURE="b0"
	while true; do
		yad ${YCOMMOPT} --window-icon "monitor" --image "view-wrapped-symbolic" --title="${VENDOR} ${MODEL}" --text="MENU > Reset > Store/restore the user saved values for the current mode" ${RESETRESTOREBUTTONS} --button="Go Back"!back:98
		reset_choice="${?}"
		if [ "${reset_choice}" -eq 1 ]; then
			ddcutil_setvcp b0 01
		elif [ "${reset_choice}" -eq 2 ]; then
			ddcutil_setvcp b0 02
		elif [ "${reset_choice}" -eq 98 ]; then
			reset_menu
		else
			exit 0
		fi
	done
}

function ddcutil_setvcp() {

	FEATURE="${1}"
	VALUE="${2}"
	RETRY=0
	while true; do
		if ddcutil --sleep-multiplier="${SLEEPMULTIPLIER}" --bus="${BUS}" --nodetect setvcp "${FEATURE}" ${VALUE}; then
			break
		elif [ "${RETRY}" = "${MAX_RETRIES}" ]; then
			break
		fi
		RETRY="$(expr "${RETRY}" + 1)"
	done
	unset FEATURE
	unset VALUE
	unset RETRY
}

function ddcutil_getvcp() {
	
	FEATURE="${1}"
	if echo "${FEATURE}" | grep -Eq "dc|60|d6|ac|ae|b2|b6|c6|c8|c9|df"; then
		true
	else
		terse="--terse"
	fi
	RETRY=0
	while true; do
		if GETVCP="$(ddcutil --sleep-multiplier="${SLEEPMULTIPLIER}" --bus="${BUS}" --nodetect ${terse} getvcp "${FEATURE}")"; then
			break
		elif [ "${RETRY}" = "${MAX_RETRIES}" ]; then
			break
		fi
		RETRY="$(expr "${RETRY}" + 1)"
	done
	unset terse
	unset FEATURE
	unset RETRY
	echo $GETVCP
}

function no_monitor() {

	yad ${YCOMMOPT} --window-icon "error" --image "error" --title="ERROR" --text="Unable to get capabilities for monitor on bus "${BUS}".
Please try to raise sleep-multiplier value." --button=Help!help-about-symbolic!Help:97 --button="Display"!monitor!"Display Selection":98 --button=Exit!exit!Exit:99
	main_choice="${?}"
	if [ "${main_choice}" -eq 97 ]; then
		yddutil_help
	elif [ "${main_choice}" -eq 98 ]; then
		exec "$yddcutilrestart" "${options}"
	elif [ "${main_choice}" -eq 99 ]; then
		exit 0
	else
		exit 0
	fi
}

function yddutil_help() {

echo "
# yddcutil

# Version:    0.1.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/yddcutil
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
yddcutil aims to be a basic universal GUI for managing compliant DCC monitors settings.
It takes advantage of ddcutil for query and change monitor settings, and yad is used for the graphical interface, so in order
to use yddcutil you must have yad and ddcutil on your system first.
Please be sure to have a working ddcutil setup before trying yddcutil. Refer to http://www.ddcutil.com

yddcutil is at very early stage, just a minority (the most important I think) of DDC features are implemented right now, including
some that I can't test.
If You want some feature to be implemented, for reporting bugs, give tips ecc... please open an issue at
https://github.com/KeyofBlueS/yddcutil/issues

### TODO
- Make our own icon set for the graphical interface, I ask you for help on this
- Implement all possible functions, even here I need Your collaboration

### INSTALL
curl -o /tmp/yddcutil.sh 'https://raw.githubusercontent.com/KeyofBlueS/yddcutil/master/yddcutil.sh'
sudo mkdir -p /opt/yddcutil/
sudo mv /tmp/yddcutil.sh /opt/yddcutil/
sudo chown root:root /opt/yddcutil/yddcutil.sh
sudo chmod 755 /opt/yddcutil/yddcutil.sh
sudo chmod +x /opt/yddcutil/yddcutil.sh
sudo ln -s /opt/yddcutil/yddcutil.sh /usr/local/bin/yddcutil

### USAGE

$ yddcutil

### IMPORTANT NOTE ABOUT --sleep-multiplier and --max-retries options:
Lowering --sleep-multiplier can really make yddcutil faster, but lowering it too much can only make speed worse and increase the
chances to get/set incorrect values. In this last case, You could increase --max-retries value to have the possibility to get/set correct values
but bear in mind that doing so will make speed even worse.
Just find the right balance between --sleep-multiplier and --max-retries options and remember that a monitor could react differently
from another one. The default values should be ok for most monitors.

Options:
-b, --bus <bus-number>		I2C bus number
-s, --sleep-multiplier <VALUE>	Applies a multiplication factor to the DDC/CI specified sleep times (Default 0.500)
-m, --max-retries <VALUE>	Times setvcp/getvcp must be tried again if their exit status is non zero (Default 15)
-h, --help			Show this help
" |	yad ${YCOMMOPT} --no-markup --vscroll-policy=always --window-icon "monitor" --image "help-about-symbolic" --title="Help" --maximized --text-info --button="Go Back"!back:98
	help_choice="${?}"
	if [ "${help_choice}" -eq 98 ]; then
		$step
	else
		exit 0
	fi
}

function givemehelp() {

echo "
# yddcutil

# Version:    0.1.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/yddcutil
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIPTION
yddcutil aims to be a basic universal GUI for managing compliant DCC monitors settings.
It takes advantage of ddcutil for query and change monitor settings, and yad is used for the graphical interface, so in order
to use yddcutil you must have yad and ddcutil on your system first.
Please be sure to have a working ddcutil setup before trying yddcutil. Refer to http://www.ddcutil.com

yddcutil is at very early stage, just a minority (the most important I think) of DDC features are implemented right now, including
some that I can't test.
If You want some feature to be implemented, for reporting bugs, give tips ecc... please open an issue at
https://github.com/KeyofBlueS/yddcutil/issues

### TODO
- Make our own icon set for the graphical interface, I ask you for help on this
- Implement all possible functions, even here I need Your collaboration

### INSTALL
curl -o /tmp/yddcutil.sh 'https://raw.githubusercontent.com/KeyofBlueS/yddcutil/master/yddcutil.sh'
sudo mkdir -p /opt/yddcutil/
sudo mv /tmp/yddcutil.sh /opt/yddcutil/
sudo chown root:root /opt/yddcutil/yddcutil.sh
sudo chmod 755 /opt/yddcutil/yddcutil.sh
sudo chmod +x /opt/yddcutil/yddcutil.sh
sudo ln -s /opt/yddcutil/yddcutil.sh /usr/local/bin/yddcutil

### USAGE

$ yddcutil

### IMPORTANT NOTE ABOUT --sleep-multiplier and --max-retries options:
Lowering --sleep-multiplier can really make yddcutil faster, but lowering it too much can only make speed worse and increase the
chances to get/set incorrect values. In this last case, You could increase --max-retries value to have the possibility to get/set correct values
but bear in mind that doing so will make speed even worse.
Just find the right balance between --sleep-multiplier and --max-retries options and remember that a monitor could react differently
from another one. The default values should be ok for most monitors.

Options:
-b, --bus <bus-number>		I2C bus number
-s, --sleep-multiplier <VALUE>	Applies a multiplication factor to the DDC/CI specified sleep times (Default 0.500)
-m, --max-retries <VALUE>	Times setvcp/getvcp must be tried again if their exit status is non zero (Default 15)
-h, --help			Show this help
"
if [ -n "${INVALID}" ]; then
	exit 1
else
	exit 0
fi
}

yddcutilrestart=$(readlink -f "${0}")
options="$(echo "${@}" | sed -E 's/[-]?-b[b]?[u]?[s]?[ ]?[[:digit:]]+//g')"
YCOMMOPT='--center --image-on-top --wrap --sticky --on-top --buttons-layout=spread'
MAX_RETRIES_DEFAULT=15
SLEEPMULTIPLIER_DEFAULT=0.500

for opt in "$@"; do
	shift
	case "$opt" in
		'--bus')				set -- "$@" '-b' ;;
		'--sleep-multiplier')	set -- "$@" '-s' ;;
		'--max-retries')		set -- "$@" '-m' ;;
		'--help')				set -- "$@" '-h' ;;
		*)						set -- "$@" "$opt"
	esac
done

while getopts ":b:s:m:h" opt; do
	case ${opt} in
		b ) BUS=$OPTARG
		;;
		s ) SLEEPMULTIPLIER=$OPTARG
		;;
		m ) MAX_RETRIES=$OPTARG
		;;
		h ) givemehelp
		;;
		*) INVALID=1; echo -e "\e[1;31m## ERROR: invalid option $OPTARG\e[0m" && givemehelp
	esac
done

if echo "${MAX_RETRIES}" | grep -Eq '^[[:digit:]]+$'; then
	true
else
	echo -e "\e[1;33mwarning: invalid or empty max-retries. Set to "${MAX_RETRIES_DEFAULT}"\e[0m"
	MAX_RETRIES="${MAX_RETRIES_DEFAULT}"
fi

if echo "${SLEEPMULTIPLIER}" | grep -Eq '^[[:digit:]]*.?[[:digit:]]+$'; then
	true
else
	echo -e "\e[1;33mwarning: invalid or empty sleep-multiplier. Set to "${SLEEPMULTIPLIER_DEFAULT}"\e[0m"
	SLEEPMULTIPLIER="${SLEEPMULTIPLIER_DEFAULT}"
fi

if echo "${BUS}" | grep -Eq '^[[:digit:]]+$'; then
	load_menu_items
else
	echo -e "\e[1;33mwarning: invalid or empty bus number. Redirecting to display selection\e[0m"
	display_selection
fi
