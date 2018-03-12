#!/bin/bash

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )
currentDate=$( date "+%m/%d/%y %H:%M:%S" )

# Jamf Pro doesn't seem to like having the ")" on the same line as the 'EOF'.

ticketDescription=$( osascript << EOF
	text returned of (display dialog "Please describe your issue/request." default answer "I just wanted to say how much I appreciate y'all in my IT department." buttons {"OK"} default button 1)
EOF
)

# This script uses the API to update an Extension Attribute based on the EA name
# (attribute ID may potentially be used as well) included in the XML below. Ensure the
# value in the XML variable for the EA name (in this case "SelfService_Help_Request") is
# updated to match your attribute.

XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>SelfService_Help_Request</name><value>( ${currentDate} ) - ${ticketDescription}</value></extension_attribute></extension_attributes></computer>"

curl -sku apiuser:password \
	https://company.jamfcloud.com/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes \
	-H "Content-type: text/xml" \
	-X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>$XMLTOWRITE"