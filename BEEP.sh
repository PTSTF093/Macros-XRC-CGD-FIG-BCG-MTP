#!/bin/bash
#
#
#
#
#		Macro monitorização XRC MTP
#
#
#
#
#



function BEEP
{
	for i in {1..3}
	do
		#printf '\7'
		paplay beep-30.wav
		sleep 0.5
	done
}

BEEP
