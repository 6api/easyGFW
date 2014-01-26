#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

if [ $(id -u) != "0" ]; then
	printf "Error: You must be root to run this script!"
	exit 1
fi

GFW_PATH=`pwd`
if [ `echo $GFW_PATH | awk -F/ '{print $NF}'` != "easyGFW" ]; then
	clear && echo "Please enter easyGFW script path:"
	read -p "(Default path: ${GFW_PATH}):" GFW_PATH
	[ -z "$GFW_PATH" ] && GFW_PATH=$(pwd)
	cd $GFW_PATH/
fi

clear
echo "#############################################################"
echo "# CentOS VPN and Socks Server 5 Auto Install Script"
echo "# Env: Redhat/CentOS"
echo "# Version: $(awk '/version/{print $2}' $GFW_PATH/Changelog)"
echo "#"
echo "# All rights reserved."
echo "# Distributed under the GNU General Public License, version 3.0."
echo "#"
echo "#############################################################"
echo ""

echo "Please enter the server IP address:"
TEMP_IP=`ifconfig |grep 'inet' | grep -Evi '(inet6|127.0.0.1)' | awk '{print $2}' | cut -d: -f2 | tail -1`
read -p "(e.g: $TEMP_IP):" IP_ADDRESS
if [ -z $IP_ADDRESS ]; then
	IP_ADDRESS="$TEMP_IP"
fi
echo "---------------------------"
echo "IP address = $IP_ADDRESS"
echo "---------------------------"
echo ""

echo "Please choose server software! (1:VPN,2:SS5,3:VPN+SS5) (1/2/3)"
read -p "(Default: 3):" SOFTWARE
if [ -z $SOFTWARE ]; then
	SOFTWARE="3"
fi
echo "---------------------------"
echo "You choose = $SOFTWARE"
echo "---------------------------"
echo ""

if [ "$SOFTWARE" != 1 ];then

	echo "Is SS5 need auth ? (y/n)"
	read -p "(Default : n):" AUTH
	if [ -z $AUTH ]; then
		AUTH="n"
	fi
	echo "---------------------------"
	echo "You choose = $AUTH"
	echo "---------------------------"
	echo ""

	if [ "$SOFTWARE" = 3 ];then
		if [ "$AUTH" != 'n' ];then
			echo "Please enter the VPN/SS5 username:"
			read -p "(Default username: xiaosong):" USERNAME
			if [ -z $USERNAME ]; then
				USERNAME="xiaosong"
			fi
			echo "---------------------------"
			echo "VPN/SS5 username = $USERNAME"
			echo "---------------------------"
			echo ""

			echo "Please enter the VPN/SS5 password:"
			read -p "(Default password: fuckGFW123):" PASSWORD
			if [ -z $PASSWORD ]; then
				PASSWORD="fuckGFW123"
			fi
			echo "---------------------------"
			echo "VPN/SS5 password = $PASSWORD"
			echo "---------------------------"
			echo ""
		else
			echo "Please enter the VPN username:"
			read -p "(Default username: xiaosong):" USERNAME
			if [ -z $USERNAME ]; then
				USERNAME="xiaosong"
			fi
			echo "---------------------------"
			echo "VPN username = $USERNAME"
			echo "---------------------------"
			echo ""

			echo "Please enter the VPN password:"
			read -p "(Default password: fuckGFW123):" PASSWORD
			if [ -z $PASSWORD ]; then
				PASSWORD="fuckGFW123"
			fi
			echo "---------------------------"
			echo "VPN password = $PASSWORD"
			echo "---------------------------"
			echo ""
		fi
	else
		if [ "$AUTH" != 'n' ];then
			echo "Please enter the SS5 username:"
			read -p "(Default username: xiaosong):" USERNAME
			if [ -z $USERNAME ]; then
				USERNAME="xiaosong"
			fi
			echo "---------------------------"
			echo "SS5 username = $USERNAME"
			echo "---------------------------"
			echo ""

			echo "Please enter the SS5 password:"
			read -p "(Default password: fuckGFW123):" PASSWORD
			if [ -z $PASSWORD ]; then
				PASSWORD="fuckGFW123"
			fi
			echo "---------------------------"
			echo "SS5 password = $PASSWORD"
			echo "---------------------------"
			echo ""
		fi
	fi
	echo "Please enter the SS5 port(建议走大端口10000以上):"
	read -p "(Default port: 18888):" PORT
	if [ -z $PORT ]; then
		PORT="18888"
	fi
	echo "---------------------------"
	echo "VPN/SS5 port = $PORT"
	echo "---------------------------"
	echo ""
else
	echo "Please enter the VPN username:"
	read -p "(Default username: xiaosong):" USERNAME
	if [ -z $USERNAME ]; then
		USERNAME="xiaosong"
	fi
	echo "---------------------------"
	echo "VPN username = $USERNAME"
	echo "---------------------------"
	echo ""

	echo "Please enter the VPN password:"
	read -p "(Default password: fuckGFW123):" PASSWORD
	if [ -z $PASSWORD ]; then
		PASSWORD="fuckGFW123"
	fi
	echo "---------------------------"
	echo "VPN password = $PASSWORD"
	echo "---------------------------"
	echo ""
fi

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}
echo "Press any key to start install..."
echo "Or Ctrl+C cancel and exit ?"
echo ""
char=`get_char`

if [ -d "$GFW_PATH/src" ];then
	\mv $GFW_PATH/src/* $GFW_PATH
fi

echo "---------- Network Check ----------"

ping -c 1 www.google.com &>/dev/null && PING=1 || PING=0

if [ "$PING" = 0 ];then
	echo "Network Failed!"
	exit
else
	echo "Network OK"
fi

#echo "---------- System Check ----------"

#if [ "$SOFTWARE" != 2 ];then
#	modprobe ppp-compress-18 &>/dev/null && PPP=1 || PPP=0

#	if [ "$PPP" = 0 ];then
#		echo "System Check Failed! Please contract your provider to enable VPN service!"
#		exit
#	else
#		echo "System OK"
#	fi
#fi

echo "---------- Update System ----------"

yum -y update

if [ ! -s /etc/yum.conf.bak ]; then
	cp /etc/yum.conf /etc/yum.conf.bak
fi
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

echo "---------- Set timezone ----------"

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

yum -y install ntp
[ "$PING" = 1 ] && ntpdate -d tw.pool.ntp.org

echo "---------- Set Library  ----------"

if [ ! `grep -iqw /lib /etc/ld.so.conf` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi

if [ ! `grep -iqw /usr/lib /etc/ld.so.conf` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi

if [ -d "/usr/lib64" ] && [ ! `grep -iqw /usr/lib64 /etc/ld.so.conf` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi

if [ ! `grep -iqw /usr/local/lib /etc/ld.so.conf` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi

ldconfig

if [ "$SOFTWARE" != 2 ];then
	echo "---------- Set Environment  ----------"

	sed -i 's,net.ipv4.ip_forward = 0,net.ipv4.ip_forward = 1,g' /etc/sysctl.conf
	sed -i 's,net.ipv4.tcp_syncookies = 1,# net.ipv4.tcp_syncookies = 1,g' /etc/sysctl.conf
	sysctl -p
fi

echo "---------- Dependent Packages ----------"

yum -y install wget tar gcc automake make iptables openssl openssl-devel

if [ "$SOFTWARE" != 2 ];then
	yum -y install ppp
fi

if [ "$SOFTWARE" != 1 ];then
	yum -y install pam-devel openldap-devel cyrus-sasl-devel
fi

echo "===================== VPN/SS5 Install ===================="

if [ "$SOFTWARE" != 2 ];then
	echo "---------- VPN ----------"

	if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
		rpm -ivh http://poptop.sourceforge.net/yum/stable/packages/pptpd-1.4.0-1.el6.x86_64.rpm
	else
		rpm -ivh http://poptop.sourceforge.net/yum/stable/packages/pptpd-1.4.0-1.el6.i686.rpm
	fi

	cat >>/etc/pptpd.conf<<-EOF
localip 192.168.0.1
remoteip 192.168.0.234-238,192.168.0.245
EOF

	cat >>/etc/ppp/options.pptpd<<-EOF
ms-dns 8.8.8.8
ms-dns 8.8.4.4
EOF


	cat >>/etc/ppp/chap-secrets<<-EOF
$USERNAME pptpd $PASSWORD *
EOF

	iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-source $IP_ADDRESS
	iptables -A FORWARD -p tcp --syn -s 192.168.0.0/24 -j TCPMSS --set-mss 1356
	iptables -I INPUT -p tcp --dport 1723 -j ACCEPT

	/etc/init.d/iptables save
	/etc/init.d/iptables restart

	/etc/init.d/pptpd restart-kill
	/etc/init.d/pptpd start

	chkconfig pptpd on
	chkconfig iptables on

	mknod /dev/ppp c 108 0
fi

if [ "$SOFTWARE" != 1 ];then
	echo "---------- SS5 ----------"

	cd $GFW_PATH/

	if [ ! -s ss5-*.tar.gz ]; then
		wget -c "http://nchc.dl.sourceforge.net/project/ss5/ss5/3.8.9-8/ss5-3.8.9-8.tar.gz"
	fi

	tar -zxf ss5-*.tar.gz
	cd ss5-*/

	./configure
	make && make install

	echo "---------- Socks Server 5 Config ----------"

	cat >>/etc/sysconfig/ss5 <<-EOF
SS5_OPTS=" -b 0.0.0.0:$PORT -u root"
EOF

	if [ "$AUTH" = 'n' ];then
		cat >>/etc/opt/ss5/ss5.conf <<-EOF
auth    0.0.0.0/0               -               -
permit -        0.0.0.0/0       -       0.0.0.0/0       -       -       -       -       -
EOF
	else
		cat >>/etc/opt/ss5/ss5.conf <<-EOF
auth    0.0.0.0/0               -               u
permit u        0.0.0.0/0       -       0.0.0.0/0       -       -       -       -       -
EOF
		echo "$USERNAME $PASSWORD" >> /etc/opt/ss5/ss5.passwd 
	fi

	if [ ! -d "src/" ];then
		mkdir -p src/
	fi
	\mv ./{*gz,*-*/} ./src >/dev/null 2>&1

	iptables -I INPUT -p tcp --dport $PORT -j ACCEPT
	/etc/rc.d/init.d/iptables save
	/etc/rc.d/init.d/iptables restart

	mv /usr/lib/ss5/mod_socks4.so /usr/lib/ss5/mod_socks4.so.bk

	chkconfig ss5 on
	chmod 0755 /etc/init.d/ss5
	/etc/init.d/ss5 restart
fi

clear
echo ""
echo "===================== Install completed ====================="
echo ""
echo "easyGFW install completed!"
echo ""
echo "Server ip address: $IP_ADDRESS"
[ "$AUTH" != "n" ] && echo "VPN/SS5 username: $USERNAME"
[ "$AUTH" != "n" ] && echo "VPN/SS5 password: $PASSWORD"
[ "$SOFTWARE" != "1" ] && echo "SS5 port: $PORT"
echo ""
echo ""
echo "============================================================="
echo ""
