#!/bin/bash

CURRENTUSER=$(python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )

appleIDList=$( defaults read /Users/${CURRENTUSER}/Library/Preferences/com.apple.commerce.plist | grep appleId | awk -F '["]' '{print $2}' )

while read -r; do
	appleIDarray+=("$REPLY")
done <<<"$appleIDList"
declare -a appleIDarray

[[ ${#appleIDarray[@]} > 1 ]] && EAResult="MULTIPLE APPLE IDs:"

for appleID in ${appleIDarray[@]}; do
	[[ ${appleID} == ${appleIDarray[0]} ]] && EAResult="${EAResult} ${appleID}"
	[[ ! ${appleID} == ${appleIDarray[0]} ]] && EAResult="${EAResult}, ${appleID}"
done

echo "<result>${EAResult}</result>"