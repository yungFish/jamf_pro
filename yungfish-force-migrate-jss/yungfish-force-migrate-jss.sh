#!/bin/bash
###############################################################################
#
#	Huge credit and thanks go to github.com/kc9wwh and github.com/haircut for
#	their projects that served as this script's inspiration. This script was designed to
#	follow the exact same workflow as haircut's migrate-jss-client project but with this
#	updated script to make the API call to un-enroll the device (using the backbone of 
#	kc9wwh's script linked below).
#
#	For reference:
#		1. haircut 'migrate-jss-client' - https://github.com/haircut/migrate-jss-client
#		2. kc9wwh 'removeJamfProMDM' - https://github.com/kc9wwh/removeJamfProMDM
#
# 	To accomplish this the following will be performed:
#			- Attempt removal via Jamf binary
#			- Attempt removal via Jamf API sending an MDM UnmanageDevice command
#
# 	REQUIREMENTS:
#			- Jamf Pro
#			- Jamf Pro API User with permission to read computer objects
#			- Jamf Pro API User with permission to send management commands
#           		- Script must be executed as root (due to profiles command)
#
# 	EXIT CODES:
#			0 - Everything is Successful
#			1 - Unable to remove MDM Profile
#
###############################################################################
#	Script Variables & Configuration                                      #
###############################################################################
# JSS URLs & script variables
old_jss_url="https://old.jamf.server"
new_jss_url="https://new.jamf.server"
apiUser="apiuser"				# API user account in the OLD Jamf Pro (old_jss_url) w/ Update permission
apiPass="password"				# Password for above API user account
clientSerial=$( system_profiler SPHardwareDataType | grep Serial |  awk '{print $NF}' )
jamfProCompID=$( /usr/bin/curl -s -u ${apiUser}:${apiPass} -H "Accept: text/xml" ${old_jss_url}/JSSResource/computers/serialnumber/${clientSerial}/subset/general | /usr/bin/xpath "//computer/general/id/text()" )

# Run mode
# 'silent' = for automated migrations; 'interactive' = invokes a UI for user alerts
runmode="interactive"

# MDM profile UID
mdm_uid="00000000-0000-0000-A000-4A414D460003"

# MDM profile filename
# Used only in last-ditch scenarios if the profile is being stubborn
mdm_filename="MDM_ComputerPrefs.plist"

# LaunchDaemon name
launchdaemon_name="com.github.haircut.migrate-jss-client"

# QuickAdd path
# Full path to the QuickAdd package. If you followed the instructions in the
# README, the default is fine.
quickadd_path="/tmp/QuickAdd-name.pkg"

# Log file path
log_file_path="/var/log/jss-client-migration.log"

# Window title heading used for all UI windows
window_title="Self Service Upgrade"
# Icon used in UI windows
icon="/Applications/Self Service.app/Contents/Resources/Self Service.icns"
# UI heading (bolded top line) for alert shown prior to migration
heading_pre="Self Service will now be upgraded."
# UI heading (bolded top line) for alert shown after completion of migration
heading_post="Self Service upgrade complete."
# UI main body message show before migration
body_pre="Self Service will automatically close to complete the upgrade. This should take about 5 minutes. Please do not open Self Service until you receive a notification that the ugprade is complete."
# UI main body for message shown after migration
body_post="Self Service has been successfully upgraded. Please follow the instructions in Self Service to approve the change and contact IT if you have any questions or need any assistance."

# locate jamf binary
jamf=$(which jamf)
# specify path to jamfHelper
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

# file logging
write_log(){
    echo "${1}"
    echo "$(date "+%Y-%m-%d %H:%M:%S") ${1}" | tee -a "${log_file_path}"
}

###############################################################################
# FUNCTIONS																	  #
###############################################################################

checkMDMProfileInstalled() {
    enrolled=`/usr/bin/profiles -C | /usr/bin/grep "00000000-0000-0000-A000-4A414D460003"`
    if [ "$enrolled" != "" ]; then
    	write_log "MDM Profile Present..."
        mdmPresent=1
    else
    	write_log "MDM Profile Successfully Removed..."
        mdmPresent=0
    fi
}

jamfUnmanageDeviceAPI() {
    /usr/bin/curl -s -X POST -H "Content-Type: text/xml" -u ${apiUser}:${apiPass} ${old_jss_url}/JSSResource/computercommands/command/UnmanageDevice/id/${jamfProCompID}
    sleep 10
    checkMDMProfileInstalled
    counter=0
    until [ "$mdmPresent" -eq "0" ] || [ "$counter" -gt "9" ]; do
        ((counter++))
        write_log "Check ${counter}/10; MDM Profile Present; waiting 18 seconds to re-check..."
        sleep 18
        checkMDMProfileInstalled
    done
}

###############################################################################
# main program                                                                #
###############################################################################

write_log "🎉 Beginning JSS migration 🎉"

# Make sure we're actually connected to the old JSS
if echo "$(${jamf} checkJSSConnection)" | grep -q "${old_jss_url}"; then
    write_log "...still connected to the old JSS ${old_jss_url}"
fi

if [[ "${runmode}" == "interactive" ]]; then
    "${jamfHelper}" -windowType utility -title "${window_title}" -heading "${heading_pre}" \
    -description "${body_pre}" -button1 "Ok" -icon "${icon}"
    write_log "...alerted user"
fi

# wait 2 seconds for  good measure
sleep 2

# close self service if running
ss_pid=$(pgrep "Self Service")
if [[ $ss_pid ]]; then
    write_log "Self Service is running"
    osascript -e "tell application \"Self Service\" to quit"
    write_log "...Closed Self Service"
fi

# remove the mdm profile
write_log "Removing MDM Profiles ..."
write_log "macOS `/usr/bin/sw_vers -productVersion`; attempting removal via jamf binary..."
/usr/local/bin/jamf removeMdmProfile -verbose
sleep 2
checkMDMProfileInstalled
if [ "$mdmPresent" == "0" ]; then
	write_log "Successfully Removed MDM Profile..."
else
	write_log "MDM Profile Present; attempting removal via API..."
	jamfUnmanageDeviceAPI
	if [ "$mdmPresent" != "0" ]; then
		write_log "Unable to remove MDM Profile; exiting..."
		exit 1
	fi
fi

# remove the current jamf framework
write_log "Removing JAMF framework"
"${jamf}" removeFramework
[[ ! $(which jamf) ]] && write_log "...successfully removed the JAMF framework" || write_log "...it doesn't appear the framework was removed; check the device to confirm proper enrollment to the new JSS"

# run the new quickadd
write_log "Installing new quickadd"
write_log "============================"
/usr/sbin/installer -pkg "${quickadd_path}" -target "/" | tee -a "${log_file_path}"
write_log "============================"
write_log "Finished installing new quickadd"

# delete the quickadd
rm "${quickadd_path}"
write_log "Removed QuickAdd package"

sleep 2

# Make sure we're now connected to the new JSS
if echo "$(${jamf} checkJSSConnection)" | grep -q "${new_jss_url}"; then
    write_log "👏 Hooray! Enrolled and connected to ${new_jss_url} 👏"
fi

# manage and enable mdm
write_log "Managing machine"
"${jamf}" manage
write_log "Enabling MDM"
"${jamf}" mdm

sleep 2

# stop, unload, remove launchdaemon
write_log "Stopping LaunchDaemon"
launchctl stop "${launchdaemon_name}"
[[ $? -gt 0 ]] && write_log "...unable to stop LaunchDaemon"

launchctl unload "/Library/LaunchDaemons/${launchdaemon_name}.plist"
[[ $? -gt 0 ]] && write_log "...unable to unload LaunchDaemon"

rm "/Library/LaunchDaemons/${launchdaemon_name}.plist"

[[ $? -gt 0 ]] && write_log "...unable to delete LaunchDaemon"
[[ $? -le 0 ]] && write_log "...deleted LaunchDaemon"

write_log "Managing machine again"
"${jamf}" manage

sleep 2

# alert user process is finished
if [[ "${runmode}" == "interactive" ]]; then
    "${jamfHelper}" -windowType utility -title "${window_title}" -heading "${heading_post}" -description "${body_post}" -button1 "Ok" -icon "${icon}"
    write_log "Alerted user migration finished"
fi

write_log "All done!"

# self destruct
write_log "💣 Self destruct! 💣"
rm "$0"
