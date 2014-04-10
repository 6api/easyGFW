## 一、简介

1. `easyGFW` 是一款`科学上网`一键部署工具，包含`VPN`和/或`SOCKET5`
2. 目前仅限在CentOS 6.0以上版本安装（32/64位均可）

## 二、安装和使用

1. 安装方法

通过Git下载（推荐）

``` shell
yum -y install git
git clone https://github.com/xiaosong/easyGFW.git
cd easyGFW && ./install.sh
```

2. 注意

查看`/etc/sysconfig/iptables`

``` shell
-A INPUT -p tcp -m tcp --dport 1723 -j ACCEPT
-A INPUT -p gre -j ACCEPT
```

上述两条规则的位置不能在任何 "-A INPUT -j REJECT ..." 的规则下面，如果有这种情形，请自行移到"-A INPUT -J REJECT ..." 的上方，保存之后，在重启`iptables`

``` shell
service iptables restart
```

## 三、联系方式

> Email: [sahala_2007#126.com](sahala_2007#126.com) （推荐）  
> Weibo：[@徐岳松](https://weibo.com/tbyuesong)  
> Home Page: [Blog](http://xiaosong.org/)  

## 四、TODO
> 增加是否支持安装VPN的判断  