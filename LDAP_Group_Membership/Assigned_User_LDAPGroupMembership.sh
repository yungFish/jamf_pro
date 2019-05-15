#!/bin/bash

IFS=$'\n'

thisSerial=$( ioreg -l | grep IOPlatformSerialNumber | awk -F '["]' '{print $4}' )

# Define our function to search LDAP
ldap_search_f () { for arg; do

ldapsearch -x \
-H "ldaps://dc01.domain.com" \
-D "directoryBindUser@domain.com" \
-w "directoryBindUserPassword" \
-b "ou=IT Staff,dc=domain,dc=com" \
-LLL "(${arg})" memberOf | awk -F '[:]' ' ( $1 == "memberOf" ) { print substr($0, index($0,$2)) } '

done
}

# Grab the user assigned to the JSS computer inventory record
assignedUser=$( curl \
	-sku apiadmin:password \
	-H "Accept: application/xml" \
	https://your.jss.com/JSSResource/computers/match/${thisSerial} | xmllint --format - | awk -F '[<>]' '/username/{print $3}')

# Determine recursive LDAP group membership		
grpMembership=$( ldap_search_f sAMAccountName=${assignedUser} )
EAResult="${grpMembership}"

while [[ -n $grpMembership ]]; do
	for grp in ${grpMembership}; do
		subGrpMembership=$( ldap_search_f distinguishedName=${grp} )
	done
	[[ -n $subGrpMembership ]] && EAResult="${EAResult}\nNESTED:${subGrpMembership}"
	[[ -n $subGrpMembership ]] && grpMembership="$subGrpMembership" || grpMembership=""
done

echo -e "<result>${EAResult}</result>"