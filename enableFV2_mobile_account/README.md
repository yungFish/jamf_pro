# enableFV2_mobile_account.sh

The enableFV2_mobile_account.sh script doesn't actually enable encryption on the computer. This script simply compares the currently logged in user to the list of mobile accounts on the machine and kicks off a JSS policy if it finds a match. This script could then be used to trigger any configuration that might differ for local accounts vs mobile accounts but YMMV.

In our case, this script is how we prevent the jamf management account from being enabled as the FV2 user. Our deployment process isn't totally 'zero-touch' yet - we still log in with the mgmt account to finish a few setup tasks before the laptop is deployed. The problem was that these last steps accidentally enabled the mgmt account for FV2 more often than we liked so this was the solution we came up with. 

To use the script as we do, you'd have a Disk Encryption Configuration in your JSS with 'Current or Next User' as the Enabled FileVault 2 User - you can use whichever recovery key type your organization requires. For this readme, ours will be called 'Institutional_NextUser'. You'd then need the following pair of policies:

	1. Run Script enableFV2_mobile_account.sh 				| Ongoing | Login 			| [SmartGroup_computers-no-FV2]
	2. Enable Disk Encryption - Institutional_NextUser		| Ongoing | encryptEvent	| [SmartGroup_computers-no-FV2]
	
The other thing we decided on with this script/workflow is that our second policy forces a reboot in the Restart Options and is set to Require FileVault 2 'At next logout.' This means the two policies above are the last steps in our deployment workflow. At the end of their orientation, the end user logs in with their AD info for the first time - this creates their mobile account on the computer as the last step in the deployment process - then the machine asks them to confirm their password for FV2 before it reboots a final time. Once it powers back up, they're free to use their laptop however they need to while the drive is encrypted in the background.

Finally, you'll want to make sure you update the device's inventory after these policies. If you don't trigger an inventory update after the second policy ('Maintenance' payload, 'Files and Processes' payload, custom event for a recon policy, etc), the enableFV2_mobile_account.sh script will continue to run at login and keep forcing reboots!