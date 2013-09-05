#! /bin/bash
#====================================================================
# install.sh
#
# CentOS VPN and Socks Server 5 Auto Install Script
#
# All rights reserved.
# Distributed under the GNU General Public License, version 3.0.
#
#
#====================================================================

if [ $(id -u) != "0" ]; then
    clear && echo "Error: You must be root to run this script!"
    exit 1
fi

GFW_PATH=`pwd`
if [ `echo $GFW_PATH | awk -F/ '{print $NF}'` != "easyGFW" ]; then
	clear && echo "Please enter easyGFW script path:"
	read -p "(Default path: ${GFW_PATH}/easyGFW):" GFW_PATH
	[ -z "$GFW_PATH" ] && GFW_PATH=$(pwd)/easyGFW
	cd $GFW_PATH/
fi

DISTRIBUTION=`awk 'NR==1{print $1}' /etc/issue`

if echo $DISTRIBUTION | grep -Eqi '(Red Hat|CentOS|Fedora|Amazon)';then
    PACKAGE="rpm"
else
    if cat /proc/version | grep -Eqi '(redhat|centos)';then
        PACKAGE="rpm"
    else
        if [[ "$PACKAGE" != "rpm" ]];then
            echo -e "\nNot supported linux distribution!"
            exit 0
        fi
    fi
fi

[ -r "$GFW_PATH/fifo" ] && rm -rf $GFW_PATH/fifo
mkfifo $GFW_PATH/fifo
cat $GFW_PATH/fifo | tee $GFW_PATH/log.txt &
exec 1>$GFW_PATH/fifo
exec 2>&1

/bin/bash ${GFW_PATH}/${PACKAGE}.sh

sed -i '/password/d' $GFW_PATH/log.txt
rm -rf $GFW_PATH/fifo
