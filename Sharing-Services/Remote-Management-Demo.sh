#!/bin/sh

##########################################################################################
#
# To save space, the full kickstart path is replaced in most examples by
# "/System/Library/yada-yada-yada/kickstart -targetdisk /". When activating any of the
# flags in this demo, use the full path and syntax of the kickstart verb as shown in 
# the first example on line 16.
#
##########################################################################################

# Define your Remote Management User
userToEnable="sshadmin"

# Start by activating Remote Management (Note: this is different from Remote Login)
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -activate 

# Enable the options found in the GUI in [ Remote Management -> "Computer Settings..." ]
/System/Library/yada-yada-yada/kickstart -targetdisk /
	-configure -clientopts
	-setmenuextra -menuextra yes 						# Enables the "Show remote management status in menu bar" option
	-setdirlogins -dirlogins  yes						# Enables Directory Server accounts for authentication. Users must be a member of one of the ARD directory groups to authenticate.

# The following binary flags determine the deployment flags found in the GUI in [ Remote Management -> "Options..." ]
# If you want to simply enable all priveleges, you can use "-privs -all" and be done with it
/System/Library/yada-yada-yada/kickstart -targetdisk /

	# Here we're enabling Remote MGMT for the desired user as defined in line 13. Additional users can be enabled when separated via comma so your $userToEnable variable could be multiple users if formatted as 'user1,user2,user3' etc.
	-configure -users "${userToEnable}" -access -on -allowAccessFor -specifiedUsers
	# The -privs flag defines which priveleges we're enabling. It's been given its own line in this demo simply for organization/readability.
	-privs
	# Enables the "Delete and replace items" option
	-DeleteFiles
	# Enables the "Observe" option as well as the "Control" sub-option below. -ObserveOnly is the alternative flag used to only allow for observation.
	-ControlObserve 
	# Enables the "Start text chat or send messages" option to allow communication between the remote mgmt technician and the end user
	-TextMessages
	# Enables the "Open and quit applications" option
	-OpenQuitApps
	# Enables the "Generate reports" option
	-GenerateReports
	# Enables the "Restart and shut down" option
	-RestartShutDown
	# Enables the "Copy items" option
	-SendFiles
	# Enables the "Change settings" option
	-ChangeSettings

# Run the following command to restart the service. Close and re-open SysPrefs and you should see your desired changes.
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -restart -agent -menu

exit 0

##########################################################################################
# Example script - from the flags above, this will enable all "Options..." options except for Restarting the machine and generating reports.
#
# #!/bin/sh
#
# userToEnable="sshadmin"
# 
# /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -activate 
# /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -configure -clientopts -setmenuextra -menuextra yes
# /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -configure -users "${userToEnable}" -access -on -allowAccessFor -specifiedUsers -privs -DeleteFiles -ControlObserve -TextMessages -OpenQuitApps -SendFiles -ChangeSettings
# /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -restart -agent -menu
#
# exit 0
#
##########################################################################################

