# jamf_pro
Jamf Pro scripts, Extension Attributes, and other assorted scripts related to MDM.

# nested_LDAP_groupMembership.sh
Jamf Pro Computer Extension Attribute that aims to find all LDAP groups (including nested groups) that the user assigned to the computer is a member of. Preliminary testing was only possible with a lightly populated directory - not many users or groups that those users could be a part of - so further tweaking is welcomed (and potentially necessary).

Output currently returns membership in the format as shown in the included 'LDAP_group_membership_EA.png' screenshot. Modifying the script output should allow the EA to meet any other visual preference or export format needs.
