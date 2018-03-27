#!/bin/bash

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

potentiallyIlliterate=$( osascript << EOF
	button returned of ( display dialog "How do you pronounce the '.gif' file extension? With a hard g like 'gift' or with a soft g, pronounced like the peanut butter?" buttons {"GIF", "JIF"} with title "Getting to know you!" )
EOF
)

GIFTOWRITE="<computer><extension_attributes><extension_attribute><name>Hard_or_Soft</name><value>${potentiallyIlliterate}</value></extension_attribute></extension_attributes></computer>"

curl -sku apiuser:password \
    https://yourcompany.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$GIFTOWRITE"
	
if [[ ${potentiallyIlliterate} == "JIF" ]]; then

jamf policy -trigger softies

elif [[ ${potentiallyIlliterate} == "GIF" ]]; then

FIXTOWRITE="<computer><extension_attributes><extension_attribute><name>gif_expansion</name><value>gif</value></extension_attribute></extension_attributes></computer>"

curl -sku apiuser:password \
	https://yourcompany.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$FIXTOWRITE"
	
osascript << EOF
    display dialog "Thanks for participating - welcome to the team!" buttons {"No problem!"} with title "Getting to know you!"
EOF

fi
