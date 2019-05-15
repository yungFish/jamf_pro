#!/bin/sh

userToEnable="sshadmin"

/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -activate 
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -configure -clientopts -setmenuextra -menuextra yes
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -configure -users "${userToEnable}" -access -on -allowAccessFor -specifiedUsers -privs -DeleteFiles -ControlObserve -TextMessages -OpenQuitApps -SendFiles -ChangeSettings -RestartShutDown -GenerateReports
/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -targetdisk / -restart -agent -menu

exit 0