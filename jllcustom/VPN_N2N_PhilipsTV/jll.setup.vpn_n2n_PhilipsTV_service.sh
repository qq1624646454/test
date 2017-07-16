#!/bin/bash
#
#Copyright (c) 2016-2100.  jielong_lin(493164984@qq.com)  All rights reserved.
#

###############################################
# VPN N2N PhilipsTV Service
###############################################

if [ x"`whoami`" != x"root" ]; then
    echo "  Sorry, Please run as root"
    exit 0
fi

if [ ! -e "/etc/rc.local" ]; then
    echo "  Sorry, Please check if /etc/rc.local exist or not"
    exit 0
fi

if [ ! -e "/etc/profile" ]; then
    echo "  Sorry, Please check if /etc/profile exist or not"
    exit 0
fi


GvSuperNode=106.186.30.16:6489

GvTunIpAddress=10.1.1.110
GvTunMacAddress=ae:3d:7e:c8:c5:aa
GvTunDevice=PhilipsTV_S

GvAccount=jielong_lin
GvPassword=jielong_lin

GvFileName=VPN_N2N_PhilipsTV_Service

#####
##### /etc/rc.local
#####

GvSym="/etc/rc.local.${GvFileName}"

GvFlags=$(/bin/grep -iwnr "\. ${GvSym}" "/etc/rc.local")
if [ x"${GvFlags}" = x ]; then
echo "  Add ${GvSym} for /etc/rc.local"
/bin/cat >${GvSym}<<EOF
#!/bin/sh
#
# Copyright (c) 2016-2100.  jielong_lin(493164984@qq.com)  All rights reserved.
#

###
### . ${GvSym} by /etc/rc.local
###
GvSuperNode=${GvSuperNode}

GvTunIpAddress=${GvTunIpAddress}
GvTunMacAddress=${GvTunMacAddress}
GvTunDevice=${GvTunDevice}

GvAccount=${GvAccount}
GvPassword=${GvPassword}

/usr/sbin/edge -d \${GvTunDevice}     \\
               -m \${GvTunMacAddress} \\
               -c \${GvAccount}       \\
               -k \${GvPassword}      \\
               -a \${GvTunIpAddress}  \\
               -l \${GvSuperNode}  >/dev/null &

EOF
/bin/chmod +x ${GvSym}

GvF=
for GvF in $(/bin/sed -n "/exit/=" "/etc/rc.local"); do
    echo "  Checking: 'exit' is at line:${GvF} of /etc/rc.local"
done
if [ x"${GvF}" = x ]; then
    echo "  Modifying: '. ${GvSym}' is inserted at the end line of /etc/rc.local"
    echo ". ${GvSym}" >> /etc/rc.local 
else
    #((GvF=GvF-1))
    #if [ \${GvF} -le 1 ]; then
    #    GvF=1
    #fi 
    echo "  Modifying: '. ${GvSym}' is inserted at line:${GvF} of /etc/rc.local"
    /bin/sed "${GvF} i \. ${GvSym}" -i /etc/rc.local
fi

else
    echo "  Information: Nothing to do for /etc/rc.local"
fi




#####
##### /etc/profile 
#####

GvSym="/etc/profile.${GvFileName}"

GvFlags=$(/bin/grep -iwnr "\. ${GvSym}" "/etc/profile")
if [ x"${GvFlags}" = x ]; then
echo "  Add ${GvSym} for /etc/profile"
/bin/cat >${GvSym}<<EOF
#!/bin/sh
#
# Copyright (c) 2016-2100.  jielong_lin(493164984@qq.com)  All rights reserved.
#
# prevent from ssh sign failure

###
### . ${GvSym} by /etc/profile
###

if [ x"\`whoami\`" != x"root" ]; then
    echo " I am \`whoami\` for ${GvFileName}"
else

    GvTunDevice=${GvTunDevice}

    GvTunMTU=\$(/sbin/ifconfig \${GvTunDevice} \\
               | /bin/grep "MTU:" \\
               | /usr/bin/awk -F':' '{print \$2}' \\
               | /usr/bin/awk '{print \$1}')
    if [ x"\${GvTunMTU}" = x ]; then
        echo "Fatal Error because can't get MTU from \"\${GvTunDevice}\"" \\
             >/Error_VPN_N2N_\$(date +%Y_%m_%d__%H_%M_%S).log
    else
        if [ \${GvTunMTU} -gt 1300 ]; then
            /sbin/ifconfig \${GvTunDevice} mtu 1300
        fi
    fi

fi

EOF
/bin/chmod +x ${GvSym}

GvF=
for GvF in $(/bin/sed -n "/exit/=" "/etc/profile"); do
    echo "  Checking: 'exit' is at line:${GvF} of /etc/profile"
done
if [ x"${GvF}" = x ]; then
    echo "  Modifying: '. ${GvSym}' is inserted at the end line of /etc/profile"
    echo ". ${GvSym}" >> /etc/profile
else
    echo "  Modifying: '. ${GvSym}' is inserted at line:${GvF} of /etc/profile"
    /bin/sed "${GvF} i \. ${GvSym}" -i /etc/profile
fi

else
    echo "  Information: Nothing to do for /etc/profile"
fi

exit 0
