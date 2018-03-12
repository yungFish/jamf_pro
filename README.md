# jamf_pro
Jamf Pro scripts, Extension Attributes, and other assorted scripts related to MDM.

# nested_LDAP_groupMembership.sh
Jamf Pro Computer Extension Attribute that aims to find all LDAP groups (including nested groups) that the user assigned to the computer is a member of. Preliminary testing was only possible with a lightly populated directory - not many users or groups that those users could be a part of - so further tweaking is welcomed (and potentially necessary).

Output currently returns membership in the format as shown in the included 'LDAP_group_membership_EA.png' screenshot. Modifying the script output should allow the EA to meet any other visual preference or export format needs. (Cosmetic note: Resizing the Jamf Pro web app should keep the groups displayed in a 'pretty' one-group-per line way. The only brief exception is after the User & Location payload is edited but refreshing the page after any payload changes are saved resets the alignment.)

# Self Service ticketing system
Simple script to allow users to submit issues/help requests via Self Service. The script then populates an Extension Attribute which can be used to place the device into a smart group for dashboard display and/or email notifications and, for bonus points, as a scope exclusion to prevent users from submitting multiple incidents before the previous request has been cleared.

Obviously, a dedicated ticketing system would better allow you to track issues and requests but this may provide additional communication opportunities with advanced users or a testing group, for example.
