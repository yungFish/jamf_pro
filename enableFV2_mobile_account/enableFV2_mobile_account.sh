#!/bin/bash

# Find the computer's list of accounts that specifically mobile accounts then find the logged in user for comparison.
mobileAccountList=$( dscl . list /Users OriginalNodeName | awk '{print $1}' 2>/dev/null )
currentUser=$( /bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }' )

# Check the logged in user against known mobile accounts and set mobile status if user matches a known mobile account
for mobileAccount in ${mobileAccountList}; do
	[[ ${mobileAccount} == ${currentUser} ]] && accountStatus="mobile"
done

# Do your policy or whatever other task if the user is confirmed as a mobile user
if [[ ${accountStatus} == "mobile" ]]; then
	# jamf policy -event encryptEvent
fi
