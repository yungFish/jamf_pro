#!/bin/bash

##################################
# Define variables
##################################

IFS=$'\n'
thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

##################################
# Define ldap search function
##################################

ldap_search_f () { for arg; do

ldapsearch -x \
-o ldif-wrap=no \
-H "ldaps://your.directory.com" \
-D "serviceAccount@directory.com" \
-w "password" \
-b "ou=Users,dc=directory,dc=com" \
-LLL "(${arg})" memberOf | awk -F '[:] ' ' ( $1 == "memberOf" ) { print $2 } '

done
}

##################################
# Meat & potatoes
##################################

assignedUser=$( curl \
	-sku apiuser:password \
	-H "Accept: application/xml" \
	https://company.jamfcloud.com/JSSResource/computers/match/${thisSerial} | xmllint --format - | awk -F '[<>]' '/username/{print $3}')
		
grpMembership=$( ldap_search_f sAMAccountName=${assignedUser} )
EAResult="${grpMembership}"

for grp in ${grpMembership}; do
	nestedGroups=$( ldap_search_f distinguishedName=${grp} )
	[[ -n $nestedGroups ]] && EAResult="${EAResult}\nNESTED: ${nestedGroups}"
	until [[ -z $nestedGroups ]]; do
		for nestGrp in ${nestedGroups}; do
			nestedGroups=$( ldap_search_f distinguishedName=${nestGrp} )
			[[ -n $nestedGroups ]] && EAResult="${EAResult}\nNESTED: ${nestedGroups}"
		done
	done
done
		
echo -e "<result>${EAResult}</result>"
