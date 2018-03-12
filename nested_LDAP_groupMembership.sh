#!/bin/bash

IFS=$'\n'

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

ldap_search_f () { for arg; do

ldapsearch -x \
-H "ldaps://your.directory.com" \
-D "serviceAccount@directory.com" \
-w "password" \
-b "ou=Users,dc=directory,dc=com" \
-LLL "(${arg})" memberOf | awk -F '[:] ' ' ( $1 == "memberOf" ) { print substr($0, index($0,$2)) } '

done
}

assignedUser=$( curl \
	-sku apiuser:password \
	-H "Accept: application/xml" \
	https://company.jamfcloud.com/JSSResource/computers/match/${thisSerial} | xmllint --format - | awk -F '[<>]' '/username/{print $3}')
		
grpMembership=$( ldap_search_f sAMAccountName=${assignedUser} )
EAResult="${grpMembership}"

while [[ -n $grpMembership ]]; do
	for grp in ${grpMembership}; do
		subGrpMembership=$( ldap_search_f distinguishedName=${grp} )
		[[ -n $subGrpMembership ]] && EAResult="${EAResult}\nNESTED:${subGrpMembership}"
		[[ -n $subGrpMembership ]] && grpMembership="$subGrpMembership" || grpMembership=""
	done
done

echo -e "<result>${EAResult}</result>"