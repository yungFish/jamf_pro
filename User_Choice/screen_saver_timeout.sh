#!/bin/bash

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

moreSecure=$( osascript << EOF
	button returned of (display dialog "Please click '0 seconds' if you would like your computer to require a password immediately once the screen saver starts. Otherwise, select the 'Cancel' button." buttons {"Cancel", "0 seconds"} with title "Screen Saver settings change request" )
EOF
)

if [[ $moreSecure == "0 seconds" ]]; then

XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>Screen_Saver_zero_seconds</name><value>Requested</value></extension_attribute></extension_attributes></computer>"

curl -sku apiuser:password \
	https://company.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE"

elif [[ $moreSecure == "Cancel" ]]; then

XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>Screen_Saver_zero_seconds</name><value>Default</value></extension_attribute></extension_attributes></computer>"

curl -sku apiuser:password \
	https://company.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE"

fi
