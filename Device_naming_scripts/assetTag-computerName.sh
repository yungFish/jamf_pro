#!/bin/bash

# Set your Jamf Pro server information
jpsURL="https://yourInstance.jamfcloud.com/JSSResource"
jpsUser="apiuser"
jpsPass='apipassword'

# Assign our computer's serial number to a variable
thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

# Make an API call to your Jamf Pro server to get this computer's Asset Tag.
jpsAssetTag=$( curl -sku ${jpsUser}:${jpsPass} -H "Accept: text/xml" ${jpsURL}/computers/serialnumber/${thisSerial} | xmllint --format - | awk -F '[<>]' '/asset_tag/{print $3}' )

# Leverage the jamf binary to assign the Asset Tag value in the computer's inventory
# record to the local ComputerName, HostName, and LocalHostName values.
# jamf setComputerName -name "${jpsAssetTag}"
echo -e "Your computer name will be \"${jpsAssetTag}\""

exit 0
