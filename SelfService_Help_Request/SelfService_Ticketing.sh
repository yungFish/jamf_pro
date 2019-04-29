#!/bin/bash
##########################################################################################
#
# This script uses the API to update an Extension Attribute by the EA name included in
# the $XMLTOWRITE variable below. Ensure the value in the $EAName variable
# (in this case "SelfService_Help_Request") is updated for your attribute/environment.
#
##########################################################################################
#
# 2019-04-09:	Cleaned up user cancel/escape input
#		Added the option to set defaultTicketText to parameter 4
#
##########################################################################################

# set variables for JSS creds, URL, and required Extension Attribute info
thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '"' '{print $4}' )
JSSAdmin="apiusername"
JSSPassw="password"
JSSURL="https://yourorganization.jamfcloud.com"
EAName="SelfService_Help_Request"

[[ -n "$4" ]] && defaultTicketText="$4"
[[ -z "$4" ]] && defaultTicketText="Lorem ipsum dolor sit amet"

# Call an osascript dialog box to allow the end user to submit an issue/make a request
ticketSubmission=$( osascript -e "display dialog \"Please describe your issue/request.\" default answer \"${defaultTicketText}\" buttons {\"Cancel\",\"OK\"} default button {\"OK\"}" )

# assign the button selected and text submitted to their corresponding variables
ticketButton=$( echo "${ticketSubmission}" | awk -F "button returned:" '{print $2}' )
ticketDescription=$( echo "${ticketSubmission}" | awk -F "text returned:" '{print $2}' )

# Exit script if the end user selects the 'Cancel' button or if their text matches
# the $defaultTicketText
if [[ "${ticketButton}" == "Cancel" || "${ticketDescription}" == "${defaultTicketText}" ]]; then
	osascript -e display dialog "Thanks!" buttons {"OK"} default button 1
	exit 1
fi	

# PUT the submitted text to the value of your corresponding EA
if [[ -n "${ticketDescription}" ]]; then
	osascript -e "display dialog \"Thanks for letting us know!\" default button {\"OK\"}"
	
	XMLTOWRITE="<computer><extension_attributes><extension_attribute><name>${EAName}</name><value>[$( date '+%Y-%m-%d_%H:%M:%S' )] - ${ticketDescription}</value></extension_attribute></extension_attributes></computer>"
	curl -sku ${JSSAdmin}:${JSSPassw} ${JSSURL}/JSSResource/computers/serialnumber/${thisSerial}/subset/extensionattributes -H "Content-type: text/xml" -X PUT -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>${XMLTOWRITE}"
fi

exit 0
