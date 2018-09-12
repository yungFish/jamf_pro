#!/bin/bash

mobileAccountList=$( dscl . list /Users OriginalNodeName | awk '{print $1}' 2>/dev/null )
currentUser=$( /bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }' )

accountStatus="local"

for mobileAccount in ${mobileAccountList}; do
	
	[[ ${mobileAccount} == ${currentUser} ]] && accountStatus="mobile"
	
done

if [[ ${accountStatus} == "mobile" ]]; then

# 	jamf policy -event encryptEvent
	
fi
