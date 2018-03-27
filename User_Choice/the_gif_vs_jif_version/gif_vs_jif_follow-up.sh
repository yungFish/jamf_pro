#!/bin/bash

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

osascript << EOF
tell application "System Preferences"
	quit
end tell
delay 2
tell application "System Preferences"
	activate
	delay 0.5
	activate
	set keyboardPane to "com.apple.preference.keyboard"
	set the current pane to pane id keyboardPane
	reveal anchor "Text" of pane id keyboardPane
	delay 0.5
end tell
tell application "System Events"
	click UI element 1 of group 1 of tab group 1 of window "Keyboard" of application process "System Preferences"
	delay 0.2
	keystroke "gif"
	delay 0.2
	keystroke "\t"
	delay 0.2
	keystroke "jif"
	delay 0.5
	keystroke "\r"
end tell
EOF

sleep 1

lastChance=$( osascript << EOF
	button returned of ( display dialog "I'll ask you one more time: How do you pronounce the '.gif' file extension?" buttons {"GIF", "JIF"} with title "I bet you give the best jifts at \$yourPreferredWinterHoliday!" )
EOF
)

if [[ ${lastChance} == "JIF" ]]; then

osascript << EOF
tell application "System Preferences"
	quit
end tell
display dialog "Whatever you say, Boss." buttons {"Peanut Butter!"} with title "If that's how you think you say it..."
EOF

sleep 0.2

JIFTOWRITE="<computer><extension_attributes><extension_attribute><name>gif_expansion</name><value>jif</value></extension_attribute></extension_attributes></computer>"

curl -sku apiuser:password \
	https://yourcompany.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$JIFTOWRITE"
		
elif [[ ${lastChance} == "GIF" ]]; then
	
GIFTOWRITE="<computer><extension_attributes><extension_attribute><name>Hard_or_Soft</name><value>${lastChance}</value></extension_attribute></extension_attributes></computer>"
FIXTOWRITE="<computer><extension_attributes><extension_attribute><name>gif_expansion</name><value>gif</value></extension_attribute></extension_attributes></computer>"
	
curl -sku apiuser:password \
	https://yourcompany.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$GIFTOWRITE"
	
curl -sku apiuser:password \
	https://yourcompany.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$FIXTOWRITE"

osascript << EOF
    display dialog "Smart move. I'll let you clean up that text replacement." buttons {"Close one!"} with title "Nice recovery, pal."
EOF

fi
