#!/bin/bash

##########################################################################################
#
# Shouts out to the StackExchange article below for providing the necessary commands.
# https://superuser.com/questions/166179/how-to-enable-remote-access-for-another-account-on-mac-remotely-via-ssh
#
##########################################################################################

userToEnable="yourSSHuser"

# Turn on SysPrefs -> Sharing -> "Remote Login" (Note: this is different from "Remote Management")
/usr/sbin/systemsetup -setremotelogin on

# Enable the desired user for Remote Login. Repeat the two commands below as necessary for additional users.
sudo dscl . append /Groups/com.apple.access_ssh user $userToEnable

sudo dscl . append /Groups/com.apple.access_ssh groupmembers `dscl . read /Users/${userToEnable} GeneratedUID | cut -d " " -f 2`

