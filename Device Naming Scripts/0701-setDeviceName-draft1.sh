#!/bin/bash

##########################################################################################
#
# This script checks certain attributes of the device and the assigned user to then set
# the device name based on the naming convention necessary for our organization.
#
##########################################################################################
#
# 2019-06-28:	Created/Uploaded
#
##########################################################################################

# Record backup values 
bupComputerName=$( /usr/sbin/scutil --get ComputerName )
bupHostName=$( /usr/sbin/scutil --get HostName )
bupLocalHostName=$( /usr/sbin/scutil --get LocalHostName )

# Modify the variable below as necessary for different buildings. Certainly could be
# re-written with some clever use of 'case' to set the prefix automatically. Was easier
# when writing to simply modify the variable below and re-upload to Jamf Pro as
# separate script(s).
Prefix="PREFIX"

# Set necessary variables for device type and assigned user as expected by organizational
# naming convention.
currentUser=$( python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");' )
macModel=$( /usr/sbin/sysctl -n hw.model | tr -c "[:alpha:]" "\n" )

# Echo backup info to jamf.log
echo "========== PROCESS START TIMSTAMP: $( date '+%Y.%m.%d_%H:%M:%S' ) =========="
echo ""
echo "Backup of current values for device name attributes to be changed..."
echo "Backup-ComputerName: \"${bupComputerName}\""
echo "Backup-HostName: \"${bupHostName}\""
echo "Backup-LocalHostName: \"${bupLocalHostName}\""
echo ""

# Echo new device name values to jamf.log
echo "Setting computer name..."
echo "Building Prefix: \"${bldgPrefix}\""
echo "Assigned User: \"${currentUser}\""		# Should be safe to rely on username for device naming in this manner since Jamf Connect Login will ensure local user names match an Okta user.

# Check against device type cases to determine proper suffix then name device accordingly.
case $macModel in
	
	MacBookPro )
	echo "Model suffix: \"-MBP\""
	jamf setComputerName -name "${Prefix}-${currentUser}-MBP"
	echo "COMPUTER NAME SET - ComputerName, HostName, and LocalHostName set to: \"W-${currentUser}-MBP\""
	;;
	MacBookAir )
	echo "Model suffix: \"-MBA\""
	jamf setComputerName -name "${Prefix}-${currentUser}-MBA"
	echo "COMPUTER NAME SET - ComputerName, HostName, and LocalHostName set to: \"W-${currentUser}-MBA\""
	;;
	MacBook )
	echo "Model suffix: \"-MB\""
	jamf setComputerName -name "${Prefix}-${currentUser}-MB"
	echo "COMPUTER NAME SET - ComputerName, HostName, and LocalHostName set to: \"W-${currentUser}-MB\""
	;;

esac

exit 0