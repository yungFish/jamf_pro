#!/bin/bash

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '"' '{print $4}' )

JSSURL="https://yourinstance.jamfcloud.com"
JSSADMIN='apiadmin'
JSSPassw='password'
EAName="Restrictions-Temp-Removal"

XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>${EAName}</name><value>[Admin login - $( date '+%Y-%m-%d_%H:%M:%S' ) ]</value></extension_attribute></extension_attributes></computer>"
	curl -sku ${JSSAdmin}:${JSSPassw} ${JSSURL}/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes -H "Content-type: text/xml" -X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${XMLTOWRITE}"
	
