#!/bin/bash
if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

if [[ -f /etc/init.d/aegis ]] || [[ -f /etc/systemd/system/aliyun.service ]]; then
systemctl stop aegis || true
systemctl disable aegis || true
rm -rf /etc/init.d/aegis || true
systemctl stop aliyun || true
systemctl disable aliyun || true
systemctl stop cloud-config || true
systemctl disable cloud-config || true
systemctl stop cloud-final || true
systemctl disable cloud-final || true
systemctl stop cloud-init-local.service || true
systemctl disable cloud-init-local.service || true
systemctl stop cloud-init || true
systemctl disable cloud-init || true
systemctl stop exim4 || true
systemctl disable exim4 || true
systemctl stop apparmor || true
systemctl disable apparmor || true
rm -rf /etc/systemd/system/aliyun.service || true
rm -rf /lib/systemd/system/cloud-config.service || true
rm -rf /lib/systemd/system/cloud-config.target || true
rm -rf /lib/systemd/system/cloud-final.service || true
rm -rf /lib/systemd/system/cloud-init-local.service || true
rm -rf /lib/systemd/system/cloud-init.service || true
systemctl daemon-reload || true
fi
#######color code############
ERROR="31m"      # Error message
SUCCESS="32m"    # Success message
WARNING="33m"   # Warning message
INFO="36m"     # Info message
LINK="92m"     # Share Link Message
#############################
cipher_server="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"
cipher_client="ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA"
#############################
colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}
#########Domain resolve verification###################
isresolved(){
    if [ $# = 2 ]
    then
        myip=$2
    else
        myip=`curl --silent http://dynamicdns.park-your-domain.com/getip`
    fi
    ips=(`nslookup $1 1.1.1.1 | grep -v 1.1.1.1 | grep Address | cut -d " " -f 2`)
    for ip in "${ips[@]}"
    do
        if [ $ip == $myip ]
        then
            return 0
        else
            continue
        fi
    done
    return 1
}
###############User input################
userinput(){
whiptail --title "User choose" --checklist --separate-output --nocancel "Press Space to Choose:(Trojan-GFW Nginx and BBR has been included)" 20 78 8 \
"1" "系统升级(System Upgrade)" on \
"2" "仅启用TLS1.3(TLS1.3 ONLY)" off \
"3" "安装V2ray(Vmess+Websocket+TLS+Nginx)" off \
"4" "安装Shadowsocks(Shadowsocks+Websocket+TLS+Nginx)" off \
"5" "安装Dnsmasq(Dns cache)" on \
"6" "安装Qbittorrent(Nginx Https Proxy)" off \
"7" "安装Aria2" off \
"8" "安装BBRPLUS(not recommended because BBR has been included)" off 2>results

while read choice
do
  case $choice in
    1) 
    system_upgrade=1
    ;;
    2) 
    tls13only=1
    ;;
    3) 
    install_v2ray=1
    ;;
    4) 
    install_ss=1
    ;;
    5) 
    dnsmasq_install=1
    ;;
    6)
    install_qbt=1
    ;;
    7)
    install_aria=1
    ;;
    8)
    install_bbrplus=1
    ;;
    *)
    ;;
  esac
done < results
domain=$(whiptail --inputbox --nocancel "朽木不可雕也，糞土之牆不可污也，快输入你的域名并按回车" 8 78 --title "Domain input" 3>&1 1>&2 2>&3)
while [[ -z $domain ]]; do
domain=$(whiptail --inputbox --nocancel "看什么看，快输入你的域名并按回车" 8 78 --title "Domain input" 3>&1 1>&2 2>&3)
done
password1=$(whiptail --passwordbox --nocancel "別動不動就爆粗口，你把你媽揣兜了隨口就說，快输入你想要的密码一并按回车" 8 78 --title "password1 input" 3>&1 1>&2 2>&3)
while [[ -z $password1 ]]; do
password1=$(whiptail --passwordbox --nocancel "你到底想干啥，你把你媽揣兜了隨口就說，快输入你想要的密码一并按回车" 8 78 --title "password1 input" 3>&1 1>&2 2>&3)
done
password2=$(whiptail --passwordbox --nocancel "你別逼我在我和你全家之間加動詞或者是名詞啊，快输入想要的密码二并按回车" 8 78 --title "password2 input" 3>&1 1>&2 2>&3)
while [[ -z $password2 ]]; do
password2=$(whiptail --passwordbox --nocancel "你是不是想找死，快输入想要的密码二并按回车" 8 78 --title "password2 input" 3>&1 1>&2 2>&3)
done
if [[ $system_upgrade = 1 ]]; then
  if [[ $(lsb_release -cs) == stretch ]]; then
    if (whiptail --title "System Upgrade" --yesno "Upgrade to Debian 10?" 8 78); then
      debian10_install=1
    else
      debian10_install=0
    fi
  fi
fi

    if [[ $install_v2ray = 1 ]] && [[ $install_ss = 1 ]]; then
      path=$(whiptail --inputbox --nocancel "Put your thinking cap on.，快输入你的想要的V2ray Websocket路径并按回车" 8 78 /secret --title "Websocket path input" 3>&1 1>&2 2>&3)
      alterid=$(whiptail --inputbox --nocancel "快输入你的想要的alter id大小并按回车" 8 78 64 --title "alterid input" 3>&1 1>&2 2>&3)
      sspath=$(whiptail --inputbox --nocancel "Put your thinking cap on.，快输入你的想要的ss-Websocket路径并按回车" 8 78 /ss --title "ss-Websocket path input" 3>&1 1>&2 2>&3)
      sspasswd=$(whiptail --passwordbox --nocancel "Put your thinking cap on.，快输入你的想要的ss密码并按回车" 8 78  --title "ss-Websocket passwd" 3>&1 1>&2 2>&3)
      ssen=$(whiptail --title "SS encrypt method Menu" --menu --nocancel "Choose an option RTFM: https://www.johnrosen1.com/trojan/" 25 78 16 \
      "1" "aes-128-gcm" \
      "2" "aes-256-gcm" \
      "3" "chacha20-poly1305" 3>&1 1>&2 2>&3)
      case $ssen in
      1)
      ssmethod=aes-128-gcm
      ;;
      2)
      ssmethod=aes-256-gcm
      ;;
      3)
      ssmethod=chacha20-poly1305
      ;;
      esac
    elif [[ $install_v2ray = 1 ]]; then
      path=$(whiptail --inputbox --nocancel "Put your thinking cap on.，快输入你的想要的V2ray Websocket路径并按回车" 8 78 /secret --title "Websocket path input" 3>&1 1>&2 2>&3)
      while [[ -z $path ]]; do
      path=$(whiptail --inputbox --nocancel "你是不是想找死，快输入想要的V2ray Websocket路径并按回车" 8 78 --title "Websocket path input" 3>&1 1>&2 2>&3)
      done
      alterid=$(whiptail --inputbox --nocancel "快输入你的想要的alter id大小(只能是数字)并按回车" 8 78 64 --title "alterid input" 3>&1 1>&2 2>&3)
      while [[ -z $alterid ]]; do
      alterid=$(whiptail --inputbox --nocancel "你是不是想找死，快输入想要的alter id大小(只能是数字)二并按回车" 8 78 --title "alterid input" 3>&1 1>&2 2>&3)
      done
    elif [[ $install_ss = 1 ]]; then
      sspath=$(whiptail --inputbox --nocancel "Put your thinking cap on.，快输入你的想要的ss-Websocket路径并按回车" 8 78 /ss --title "ss-Websocket path input" 3>&1 1>&2 2>&3)
      while [[ -z $sspath ]]; do
      sspath=$(whiptail --inputbox --nocancel "你是不是想找死，快输入想要的ss-Websocket路径并按回车" 8 78 --title "ss-Websocket path input" 3>&1 1>&2 2>&3)
      done
      sspasswd=$(whiptail --passwordbox --nocancel "Put your thinking cap on.，快输入你的想要的ss密码并按回车" 8 78  --title "ss passwd input" 3>&1 1>&2 2>&3)
      while [[ -z $sspasswd ]]; do
      sspasswd=$(whiptail --passwordbox --nocancel "你是不是想找死，快输入想要的ss密码并按回车" 8 78 --title "ss passwd input" 3>&1 1>&2 2>&3)
      done
      ssen=$(whiptail --title "SS encrypt method Menu" --menu --nocancel "Choose an option RTFM: https://www.johnrosen1.com/trojan/" 25 78 16 \
      "1" "aes-128-gcm" \
      "2" "aes-256-gcm" \
      "3" "chacha20-poly1305" 3>&1 1>&2 2>&3)
      case $ssen in
      1)
      ssmethod=aes-128-gcm
      ;;
      2)
      ssmethod=aes-256-gcm
      ;;
      3)
      ssmethod=chacha20-poly1305
      ;;
      esac
      else
      echo "Continuing"
    fi
    if [[ $install_qbt = 1 ]]; then
      qbtpath=$(whiptail --inputbox --nocancel "Put your thinking cap on.，快输入你的想要的Qbittorrent路径并按回车" 8 78 /qbt/ --title "Qbittorrent path input" 3>&1 1>&2 2>&3)
      while [[ -z $qbtpath ]]; do
      qbtpath=$(whiptail --inputbox --nocancel "你是不是想找死，快输入想要的Qbittorrent路径并按回车" 8 78 --title "Qbittorrent path input" 3>&1 1>&2 2>&3)
      done
    fi
    if [[ $install_aria = 1 ]]; then
      ariaport=$(whiptail --inputbox --nocancel "Put your thinking cap on.，快输入你的想要的Aria2 rpc port并按回车" 8 78 6800 --title "Aria2 rpc port input" 3>&1 1>&2 2>&3)
      ariapasswd=$(whiptail --passwordbox --nocancel "Put your thinking cap on.，快输入你的想要的Aria2 rpc token并按回车" 8 78 --title "Aria2 rpc token input" 3>&1 1>&2 2>&3)
      while [[ -z $ariapasswd ]]; do
      ariapasswd=$(whiptail --passwordbox --nocancel "你是不是想找死，快输入想要的Aria2 rpc token并按回车" 8 78 --title "Aria2 rpc token input" 3>&1 1>&2 2>&3)
      done
      while [[ -z $ariaport ]]; do
      ariaport=$(whiptail --inputbox --nocancel "你是不是想找死，快输入想要的Aria2 rpc port并按回车" 8 78 --title "Aria2 rpc port input" 3>&1 1>&2 2>&3)
      done
    fi
}
###############OS detect####################
osdist(){

set -e
 if cat /etc/*release | grep ^NAME | grep CentOS; then
    dist=centos
 elif cat /etc/*release | grep ^NAME | grep Red; then
    dist=centos
 elif cat /etc/*release | grep ^NAME | grep Fedora; then
    dist=centos
 elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
    dist=ubuntu
 elif cat /etc/*release | grep ^NAME | grep Debian; then
    dist=debian
 else
  TERM=ansi whiptail --title "OS SUPPORT" --infobox "OS NOT SUPPORTED, couldn't install Trojan-gfw" 8 78
    exit 1;
 fi
}
##############Upgrade system optional########
upgradesystem(){
  if [[ $dist = centos ]]; then
    yum upgrade -y
 elif [[ $dist = ubuntu ]]; then
    export UBUNTU_FRONTEND=noninteractive 
    apt-get upgrade -q -y
    apt-get autoremove -qq -y
 elif [[ $dist = debian ]]; then
    export DEBIAN_FRONTEND=noninteractive 
    apt-get upgrade -q -y
    if [[ $debian10_install = 1 ]]; then
          cat > '/etc/apt/sources.list' << EOF
#------------------------------------------------------------------------------#
#                   OFFICIAL DEBIAN REPOS                    
#------------------------------------------------------------------------------#

###### Debian Main Repos
deb http://deb.debian.org/debian/ stable main contrib non-free
deb-src http://deb.debian.org/debian/ stable main contrib non-free

deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free

deb http://deb.debian.org/debian-security stable/updates main
deb-src http://deb.debian.org/debian-security stable/updates main

deb http://ftp.debian.org/debian buster-backports main
deb-src http://ftp.debian.org/debian buster-backports main
EOF
    apt-get update
    sudo sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
    fi
    apt-get autoremove -qq -y
 else
  clear
  TERM=ansi whiptail --title "error can't upgrade system" --infobox "error can't upgrade system" 8 78
    exit 1;
 fi
}
#########Open ports########################
openfirewall(){
  colorEcho ${INFO} "设置 firewall"
  iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
  iptables -I OUTPUT -j ACCEPT
  ip6tables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  ip6tables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
  ip6tables -I OUTPUT -j ACCEPT
  if [[ $dist = centos ]]; then
      setenforce 0  || true
          cat > '/etc/selinux/config' << EOF
SELINUX=disabled
SELINUXTYPE=targeted
EOF
    firewall-cmd --zone=public --add-port=80/tcp --permanent  || true
    firewall-cmd --zone=public --add-port=443/tcp --permanent  || true
    systemctl stop firewalld  || true
    systemctl disable firewalld || true
    yum install -y iptables-services || true
    systemctl enable iptables || true
    systemctl enable ip6tables || true
    sudo /usr/libexec/iptables/iptables.init save || true
    systemctl start iptables.service || true
 elif [[ $dist = ubuntu ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get install iptables-persistent -q -y > /dev/null
 elif [[ $dist = debian ]]; then
    export DEBIAN_FRONTEND=noninteractive 
    apt-get install iptables-persistent -q -y > /dev/null
 else
  clear
  TERM=ansi whiptail --title "error can't install iptables-persistent" --infobox "error can't install iptables-persistent" 8 78
    exit 1;
 fi
}
##########install dependencies#############
installdependency(){
    colorEcho ${INFO} "Updating system"
  if [[ $dist = centos ]]; then
    yum update -y
 elif [[ $dist = ubuntu ]]; then
    apt-get update -qq
 elif [[ $dist = debian ]]; then
    apt-get update -qq
 else
  clear
  TERM=ansi whiptail --title "error can't update system" --infobox "error can't update system" 8 78
    exit 1;
 fi
###########################################
  clear
  colorEcho ${INFO} "安装所有必备软件(Install all necessary Software)"
  if [[ $dist = centos ]]; then
    yum install -y sudo curl wget gnupg python3-qrcode unzip bind-utils epel-release chrony systemd
 elif [[ $dist = ubuntu ]] || [[ $dist = debian ]]; then
    apt-get install sudo curl xz-utils wget apt-transport-https gnupg dnsutils lsb-release python-pil unzip resolvconf ntpdate systemd dbus ca-certificates locales -qq -y
    if [[ $(lsb_release -cs) == xenial ]] || [[ $(lsb_release -cs) == trusty ]] || [[ $(lsb_release -cs) == jessie ]]; then
      TERM=ansi whiptail --title "Skipping generating QR code!" --infobox "你的操作系统不支持 python3-qrcode,Skipping generating QR code!" 8 78
      else
        apt-get install python3-qrcode -qq -y
    fi
 else
  clear
  TERM=ansi whiptail --title "error can't install dependency" --infobox "error can't install dependency" 8 78
    exit 1;
 fi
 clear
#############################################
if isresolved $domain
  then
  :
  else 
  colorEcho ${ERROR} "域名解析验证失败，请自行验证解析是否成功并且请关闭Cloudfalare CDN并检查VPS控制面板防火墙(80 443)是否打开!!!"
  colorEcho ${ERROR} "Domain verification fail,Pleae turn off Cloudflare CDN and Open port 80 443 on VPS panel !!!"
  exit -1
  clear
fi
#############################################
if [[ $system_upgrade = 1 ]]; then
upgradesystem
fi
clear
#############################################
if [[ $tls13only = 1 ]]; then
cipher_server="TLS_AES_128_GCM_SHA256"
fi
#############################################
if [[ $install_aria = 1 ]]; then
  if [[ -f /usr/bin/aria2c ]]; then
    :
    else
      apt-get install build-essential nettle-dev libgmp-dev libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev pkg-config libssl-dev autoconf automake autotools-dev autopoint libtool libuv1-dev -y
      wget https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.xz
      tar -xvf aria2-1.35.0.tar.xz
      rm aria2-1.35.0.tar.xz
      cd aria2-1.35.0
      ./configure --with-libuv --without-gnutls --with-openssl
      make -j $(grep "^core id" /proc/cpuinfo | sort -u | wc -l)
      make install
      apt remove build-essential nettle-dev libgmp-dev libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev pkg-config libssl-dev autoconf automake autotools-dev autopoint libtool libuv1-dev -y
      touch /usr/local/bin/aria2.session
      cd ..
      rm -rf aria2-1.35.0
      cat > '/etc/systemd/system/aria2.service' << EOF
[Unit]
Description=Aria2c download manager
Requires=network.target
After=network.target
    
[Service]
Type=forking
User=root
RemainAfterExit=yes
ExecStart=/usr/local/bin/aria2c --conf-path=/etc/aria2.conf --daemon
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
RestartSec=1min
Restart=on-failure
    
[Install]
WantedBy=multi-user.target
EOF
      cat > '/etc/aria2.conf' << EOF
rpc-secure=true
rpc-certificate=/etc/trojan/trojan.crt
rpc-private-key=/etc/trojan/trojan.key
## 下载设置 ##
continue=true
max-concurrent-downloads=50
split=16
min-split-size=10M
max-connection-per-server=16
lowest-speed-limit=0
#max-overall-download-limit=0
#max-download-limit=0
#max-overall-upload-limit=0
#max-upload-limit=0
disable-ipv6=false
max-tries=0
#retry-wait=0

## 进度保存相关 ##

input-file=/usr/local/bin/aria2.session
save-session=/usr/local/bin/aria2.session
save-session-interval=60
force-save=true

## RPC相关设置 ##

enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
event-poll=epoll
# RPC监听端口, 端口被占用时可以修改, 默认:6800
rpc-listen-port=$ariaport
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
rpc-secret=$ariapasswd

## BT/PT下载相关 ##
#follow-torrent=true
listen-port=51413
#bt-max-peers=55
enable-dht=true
enable-dht6=true
#dht-listen-port=6881-6999
bt-enable-lpd=true
#enable-peer-exchange=true
#bt-request-peer-speed-limit=50K
# 客户端伪装, PT需要
#peer-id-prefix=-TR2770-
#user-agent=Transmission/2.77
seed-ratio=0
# BT校验相关, 默认:true
#bt-hash-check-seed=true
bt-seed-unverified=true
bt-save-metadata=true
bt-require-crypto=true

## 磁盘相关 ##

#文件保存路径, 默认为当前启动位置
dir=/root/aria2/
#enable-mmap=true
file-allocation=none
disk-cache=64M
EOF
  fi
fi
#############################################
if [[ $dnsmasq_install = 1 ]]; then
  if [[ -f /usr/sbin/dnsmasq ]]; then
    :
    else
    if [[ $dist = centos ]]; then
    yum install -y dnsmasq  || true
 elif [[ $dist = ubuntu ]] || [[ $dist = debian ]]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get install dnsmasq -qq -y || true
 else
  clear
  TERM=ansi whiptail --title "error can't install dnsmasq" --infobox "error can't install dnsmasq" 8 78
    exit 1;
 fi
 if [[ $dist = ubuntu ]]; then
   systemctl stop systemd-resolved || true
   systemctl disable systemd-resolved || true > /dev/null
 fi
 touch /etc/dnsmasq.txt || true
      cat > '/etc/dnsmasq.txt' << EOF
####Block 360####
0.0.0.0 360.cn
0.0.0.0 360.com
0.0.0.0 360jie.com
0.0.0.0 360kan.com
0.0.0.0 360taojin.com
0.0.0.0 i360mall.com
0.0.0.0 qhimg.com
0.0.0.0 qhmsg.com
0.0.0.0 qhres.com
0.0.0.0 qihoo.com
0.0.0.0 nicaifu.com
0.0.0.0 so.com
####Block Xunlei###
0.0.0.0 xunlei.com
####Block Baidu###
0.0.0.0 baidu.cn
0.0.0.0 baidu.com
0.0.0.0 baiducontent.com
0.0.0.0 baidupcs.com
0.0.0.0 baidustatic.com
0.0.0.0 baifubao.com
0.0.0.0 bdimg.com
0.0.0.0 bdstatic.com
0.0.0.0 duapps.com
0.0.0.0 quyaoya.com
0.0.0.0 tiebaimg.com
0.0.0.0 xiaodutv.com
0.0.0.0 sina.com
EOF
     cat > '/etc/dnsmasq.conf' << EOF
port=53
domain-needed
bogus-priv
no-resolv
server=8.8.4.4#53
server=1.1.1.1#53
addn-hosts=/etc/dnsmasq.txt
interface=lo
bind-interfaces
cache-size=10000
no-negcache
log-queries 
log-facility=/var/log/dnsmasq.log 
EOF
echo "nameserver 127.0.0.1" > '/etc/resolv.conf'
systemctl restart dnsmasq || true
systemctl enable dnsmasq || true      
  fi
fi
clear
#############################################
if [[ $install_v2ray = 1 ]] || [[ $install_ss = 1 ]]; then
  installv2ray
fi
clear
#############################################
if [[ $install_qbt = 1 ]]; then
  if [[ -f /usr/bin/qbittorrent-nox ]]; then
    :
    else
  if [[ $dist = centos ]]; then
  yum install -y epel-release
  yum update -y
  yum install qbittorrent-nox -y
 elif [[ $dist = ubuntu ]]; then
    export DEBIAN_FRONTEND=noninteractive
    add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
    apt-get install qbittorrent-nox -qq -y
 elif [[ $dist = debian ]]; then
    export DEBIAN_FRONTEND=noninteractive 
    apt-get install qbittorrent-nox -qq -y
 else
  clear
  TERM=ansi whiptail --title "error can't install qbittorrent-nox" --infobox "error can't install qbittorrent-nox" 8 78
    exit 1;
 fi
      cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=man:qbittorrent-nox(1)
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
# if you have systemd >= 240, you probably want to use Type=exec instead
Type=simple
User=root
ExecStart=/usr/bin/qbittorrent-nox
TimeoutStopSec=infinity
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
fi      
fi
clear
#############################################
  curl -s https://get.acme.sh | sh
  sudo ~/.acme.sh/acme.sh --upgrade --auto-upgrade
  if [[ -f /usr/local/bin/trojan ]]; then
    :
    else
  clear
  bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
  systemctl daemon-reload      
  fi
  clear
#####################################################
  if [[ -f /etc/apt/sources.list.d/nginx.list ]]; then
    :
    else
  if [[ $dist = centos ]]; then
  yum install nginx -y
  systemctl stop nginx || true
 elif [[ $dist = debian ]] || [[ $dist = ubuntu ]]; then
  wget https://nginx.org/keys/nginx_signing.key -q
  apt-key add nginx_signing.key
  rm -rf nginx_signing.key
  touch /etc/apt/sources.list.d/nginx.list
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/$dist/ $(lsb_release -cs) nginx
deb-src https://nginx.org/packages/mainline/$dist/ $(lsb_release -cs) nginx
EOF
  apt-get remove nginx-common -qq -y
  apt-get update -qq
  apt-get install nginx -q -y
 else
  clear
  TERM=ansi whiptail --title "error can't install nginx" --infobox "error can't install nginx" 8 78
    exit 1;
 fi
fi
nginxconf
clear
}
##################################################
issuecert(){
  colorEcho ${INFO} "申请(issuing) let\'s encrypt certificate"
  if [[ -f /etc/trojan/trojan.crt ]]; then
    TERM=ansi whiptail --title "证书已有，跳过申请" --infobox "证书已有，跳过申请。。。" 8 78
    else
  mkdir /etc/trojan/ &
  rm -rf /etc/nginx/sites-available/* &
  rm -rf /etc/nginx/sites-enabled/* &
  rm -rf /etc/nginx/conf.d/*
  touch /etc/nginx/conf.d/default.conf
    cat > '/etc/nginx/conf.d/default.conf' << EOF
server {
    listen       80;
    server_name  $domain;
    root   /usr/share/nginx/html;
}
EOF
  systemctl start nginx
  sudo ~/.acme.sh/acme.sh --issue --nginx -d $domain -k ec-256 --force --log --reloadcmd "systemctl reload trojan || true"
  sudo ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/trojan/trojan.crt --keypath /etc/trojan/trojan.key --ecc
  chmod +r /etc/trojan/trojan.key
  fi
}
##################################################
renewcert(){
  sudo ~/.acme.sh/acme.sh --issue --nginx -d $domain -k ec-256 --force --log --reloadcmd "systemctl restart trojan"
}
##################################################
changepasswd(){
  colorEcho ${INFO} "配置(configing) trojan-gfw"
  if [[ -f /etc/trojan/trojan.pem ]]; then
    colorEcho ${INFO} "DH已有，跳过生成。。。"
    else
      openssl dhparam -out /etc/trojan/trojan.pem 2048
  fi
  cat > '/usr/local/etc/trojan/config.json' << EOF
{
    "run_type": "server",
    "local_addr": "::",
    "local_port": 443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$password1",
        "$password2"
    ],
    "log_level": 1,
    "ssl": {
        "cert": "/etc/trojan/trojan.crt",
        "key": "/etc/trojan/trojan.key",
        "key_password": "",
        "cipher": "$cipher_server",
        "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "prefer_server_cipher": true,
        "alpn": [
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": true,
        "session_timeout": 600,
        "plain_http_response": "",
        "curves": "",
        "dhparam": "/etc/trojan/trojan.pem"
    },
    "tcp": {
        "prefer_ipv4": true,
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": true,
        "fast_open": true,
        "fast_open_qlen": 20
    },
    "mysql": {
        "enabled": false,
        "server_addr": "127.0.0.1",
        "server_port": 3306,
        "database": "trojan",
        "username": "trojan",
        "password": ""
    }
}
EOF
}
########Nginx config for Trojan only##############
nginxtrojan(){
  colorEcho ${INFO} "配置(configing) nginx"
rm -rf /etc/nginx/sites-available/* || true
rm -rf /etc/nginx/sites-enabled/* || true
rm -rf /etc/nginx/conf.d/* || true
touch /etc/nginx/conf.d/trojan.conf
  if [[ $install_v2ray = 1 ]] && [[ $install_ss = 1 ]] && [[ $install_qbt = 1 ]]; then
      cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $path {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    location $sspath {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:20000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    location $qbtpath {
        proxy_pass              http://127.0.0.1:8080/;
        proxy_set_header        X-Forwarded-Host        \$server_name:\$server_port;
        proxy_hide_header       Referer;
        proxy_hide_header       Origin;
        proxy_set_header        Referer                 '';
        proxy_set_header        Origin                  '';
        # add_header              X-Frame-Options         "SAMEORIGIN"; # not needed since 4.1.0
        }
    location /announce {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
elif [[ $install_v2ray = 1 ]] && [[ $install_ss = 1 ]]; then
  cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $path {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    location $sspath {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:20000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
elif [[ $install_v2ray = 1 ]] && [[ $install_qbt = 1 ]]; then
        cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $path {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    location $qbtpath {
        proxy_pass              http://127.0.0.1:8080/;
        proxy_set_header        X-Forwarded-Host        \$server_name:\$server_port;
        proxy_hide_header       Referer;
        proxy_hide_header       Origin;
        proxy_set_header        Referer                 '';
        proxy_set_header        Origin                  '';
        # add_header              X-Frame-Options         "SAMEORIGIN"; # not needed since 4.1.0
        }
    location /announce {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
elif [[ $install_ss = 1 ]] && [[ $install_qbt = 1 ]]; then
        cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $sspath {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:20000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    location $qbtpath {
        proxy_pass              http://127.0.0.1:8080/;
        proxy_set_header        X-Forwarded-Host        \$server_name:\$server_port;
        proxy_hide_header       Referer;
        proxy_hide_header       Origin;
        proxy_set_header        Referer                 '';
        proxy_set_header        Origin                  '';
        # add_header              X-Frame-Options         "SAMEORIGIN"; # not needed since 4.1.0
        }
    location /announce {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
elif [[ $install_v2ray = 1 ]]; then
  cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $path {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
elif [[ $install_ss = 1 ]]; then
  cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $sspath {
        access_log off;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:20000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
elif [[ $install_qbt = 1 ]]; then
        cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $qbtpath {
        proxy_pass              http://127.0.0.1:8080/;
        proxy_set_header        X-Forwarded-Host        \$server_name:\$server_port;
        proxy_hide_header       Referer;
        proxy_hide_header       Origin;
        proxy_set_header        Referer                 '';
        proxy_set_header        Origin                  '';
        # add_header              X-Frame-Options         "SAMEORIGIN"; # not needed since 4.1.0
        }
    location /announce {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
 else
    cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
    server_name $domain;
    if (\$http_user_agent = "") { return 444; }
    root /usr/share/nginx/html/;
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Frame-Options SAMEORIGIN always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header Referrer-Policy "no-referrer";
  #add_header Content-Security-Policy "default-src 'self'; script-src 'self' https://ssl.google-analytics.com https://assets.zendesk.com https://connect.facebook.net; img-src 'self' https://ssl.google-analytics.com https://s-static.ak.facebook.com https://assets.zendesk.com; style-src 'self' https://fonts.googleapis.com https://assets.zendesk.com; font-src 'self' https://themes.googleusercontent.com; frame-src https://assets.zendesk.com https://www.facebook.com https://s-static.ak.facebook.com https://tautt.zendesk.com; object-src 'none'";
  add_header Feature-Policy "geolocation none;midi none;notifications none;push none;sync-xhr none;microphone none;camera none;magnetometer none;gyroscope none;speaker self;vibrate none;fullscreen self;payment none;";
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    return 301 https://$domain;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
 fi
nginx -s reload
systemctl restart nginx
htmlcode=$(shuf -i 1-3 -n 1)
wget https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/$htmlcode.zip -q
unzip -o $htmlcode.zip -d /usr/share/nginx/html/
rm -rf $htmlcode.zip
}
##########Nginx conf####################
nginxconf(){
    cat > '/etc/nginx/nginx.conf' << EOF
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log warn;
#pid /var/run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
  worker_connections 3000;
  use epoll;
  multi_accept on;
}

http {
  #aio threads; //Please enable it by yourself,disabled for compatibility.
  charset UTF-8;
  tcp_nodelay on;
  tcp_nopush on;
  server_tokens off;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log /var/log/nginx/access.log;


  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status $body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" "\$http_x_forwarded_for"';

  sendfile on;
  gzip on;
  gzip_comp_level 5;

  include /etc/nginx/conf.d/*.conf; 
}
EOF
}
##########Auto boot start###############
start(){
  colorEcho ${INFO} "启动(starting) trojan-gfw and nginx ing..."
  systemctl daemon-reload || true
  if [[ $install_v2ray = 1 ]] || [[ $install_ss = 1 ]]; then
    systemctl start v2ray || true
  fi
  if [[ $install_qbt = 1 ]]; then
    systemctl start qbittorrent.service || true
  fi
  if [[ $install_aria = 1 ]]; then
    systemctl start aria2 || true
  fi
  systemctl restart trojan || true
  systemctl restart nginx || true
}
bootstart(){
  colorEcho ${INFO} "设置开机自启(auto boot start) ing..."
  systemctl daemon-reload || true
  if [[ $install_v2ray = 1 ]] || [[ $install_ss = 1 ]]; then
    systemctl enable v2ray || true
  fi
  if [[ $install_qbt = 1 ]]; then
    systemctl enable qbittorrent.service || true
  fi
  if [[ $install_aria = 1 ]]; then
    systemctl enable aria2 || true
  fi
  systemctl enable nginx || true
  systemctl enable trojan || true
}
##########tcp-bbr#####################
tcp-bbr(){
  colorEcho ${INFO} "设置(setting up) TCP-BBR boost technology"
  cat > '/etc/sysctl.d/99-sysctl.conf' << EOF
net.ipv6.conf.all.accept_ra = 2
fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 4096
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_max_syn_backlog = 12800
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
  sysctl -p > /dev/null
    cat > '/etc/systemd/system.conf' << EOF
[Manager]
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=30s
#DefaultRestartSec=100ms
DefaultLimitCORE=infinity
DefaultLimitNOFILE=51200
DefaultLimitNPROC=51200
EOF
    cat > '/etc/security/limits.conf' << EOF
* soft nofile 51200
* hard nofile 51200
EOF
    cat > '/etc/profile' << EOF
if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
ulimit -SHn 51200
EOF
systemctl daemon-reload
if [[ $install_bbrplus = 1 ]]; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh)"
fi
}
############Set UP V2ray############
installv2ray(){
  bash <(curl -L -s https://install.direct/go.sh) > /dev/null
  rm -rf /etc/v2ray/config.json
  uuid=$(/usr/bin/v2ray/v2ctl uuid)
  if [[ $install_v2ray = 1 ]] && [[ $install_ss = 1 ]]; then
  cat > "/etc/v2ray/config.json" << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log"
  },
  "inbounds": [
        {
            "sniffing": {
            "enabled": true,
            "destOverride": ["http","tls"]
        },
        "port": 10000,
        "listen":"127.0.0.1",
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "$uuid",
                    "alterId": $alterid
                }
            ]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
        "path": "$path"
        }
        }
    },
    {
    "port": "20000",
    "listen": "127.0.0.1",
    "protocol": "dokodemo-door",
    "tag": "ssin",
    "settings": {
      "address": "v1.mux.cool",
      "followRedirect": false,
      "network": "tcp"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
      "path": "$sspath"
      }
    }
  },
  {
    "port": 9015,
    "listen": "127.0.0.1",
    "protocol": "shadowsocks",
    "settings": {
      "method": "$ssmethod",
      "ota": false,
      "password": "$sspasswd",
      "network": "tcp,udp"
    },
    "streamSettings": {
      "network": "domainsocket"
    }
  }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    },
    {
      "protocol": "freedom",
      "tag": "ssmux",
      "streamSettings": {
        "network": "domainsocket"
      }
    }
  ],
  "transport": {
    "dsSettings": {
      "path": "/var/run/ss-loop.sock"
    }
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "inboundTag": ["ssin"],
        "outboundTag": "ssmux"
      },
      {
        "type": "field",
        "domain": [
        "domain:baidu.com",
        "domain:qq.com",
        "domain:sina.com",
        "geosite:qihoo360"
      ],
      "outboundTag": "blocked"
      }
    ]
  }
}
EOF
elif [[ $install_ss = 1 ]]; then
  cat > "/etc/v2ray/config.json" << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log"
  },
  "inbounds": [
    {
    "port": "20000",
    "listen": "127.0.0.1",
    "protocol": "dokodemo-door",
    "tag": "ssin",
    "settings": {
      "address": "v1.mux.cool",
      "followRedirect": false,
      "network": "tcp"
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
      "path": "$sspath"
      }
    }
  },
  {
    "port": 9015,
    "listen": "127.0.0.1",
    "protocol": "shadowsocks",
    "settings": {
      "method": "$ssmethod",
      "ota": false,
      "password": "$sspasswd",
      "network": "tcp,udp"
    },
    "streamSettings": {
      "network": "domainsocket"
    }
  }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    },
    {
      "protocol": "freedom",
      "tag": "ssmux",
      "streamSettings": {
        "network": "domainsocket"
      }
    }
  ],
  "transport": {
    "dsSettings": {
      "path": "/var/run/ss-loop.sock"
    }
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "inboundTag": ["ssin"],
        "outboundTag": "ssmux"
      },
      {
        "type": "field",
        "domain": [
        "domain:baidu.com",
        "domain:qq.com",
        "domain:sina.com",
        "geosite:qihoo360"
      ],
      "outboundTag": "blocked"
      }
    ]
  }
}
EOF
  else
      cat > "/etc/v2ray/config.json" << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log"
  },
  "inbounds": [
        {
            "sniffing": {
            "enabled": true,
            "destOverride": ["http","tls"]
        },
        "port": 10000,
        "listen":"127.0.0.1",
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "$uuid",
                    "alterId": $alterid
                }
            ]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
        "path": "$path"
        }
        }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "domain": [
        "domain:baidu.com",
        "domain:qq.com",
        "domain:sina.com",
        "geosite:qihoo360"
      ],
      "outboundTag": "blocked"
      }
    ]
  }
}
EOF
  fi
}
###########Trojan Client Config#############
trojanclient(){
  touch /etc/trojan/client1.json
  touch /etc/trojan/client2.json
    cat > '/etc/trojan/client1.json' << EOF
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "$myip",
    "remote_port": 443,
    "password": [
        "$password1"
    ],
    "log_level": 1,
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "",
        "cipher": "$cipher_client",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "sni": "$domain",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "curves": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": true,
        "fast_open_qlen": 20
    }
}
EOF
    cat > '/etc/trojan/client2.json' << EOF
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "$myip",
    "remote_port": 443,
    "password": [
        "$password2"
    ],
    "log_level": 1,
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "",
        "cipher": "$cipher_client",
        "cipher_tls13": "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
        "sni": "$domain",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "curves": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "reuse_port": false,
        "fast_open": true,
        "fast_open_qlen": 20
    }
}
EOF
colorEcho ${INFO} "你的(Your) Trojan-Gfw 客户端(client) config profile 1"
cat /etc/trojan/client1.json
colorEcho ${INFO} "你的(Your) Trojan-Gfw 客户端(client) config profile 2"
cat /etc/trojan/client2.json
}
##########V2ray Client Config################
v2rayclient(){
  touch /etc/v2ray/client.json
  cat > '/etc/v2ray/client.json' << EOF
{
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 1081,
      "protocol": "socks",
      "settings":{},
      "sniffing": {
        "enabled": true,
        "destOverride": ["http","tls"]
        }
      },
    {
      "listen": "127.0.0.1",
      "port": 8001,
      "protocol": "http",
      "settings": {},
      "sniffing": {
        "enabled": true,
        "destOverride": ["http","tls"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$domain",
            "port": 443,
            "users": [
              {
                "id": "$uuid",
                "alterId": $alterid,
                "security": "auto"
              }
            ]
          }
        ]
      },
      "streamSettings": {
      "network": "ws",
      "security": "tls",
      "wsSettings": {
        "path": "$path",
        "headers": {
          "Host": "$domain"
        }
      },
      "tlsSetting": {
        "allowInsecure": false,
        "alpn": ["http/1.1","h2"],
        "serverName": "$domain",
        "allowInsecureCiphers": false,
        "disableSystemRoot": false
      },
        "sockopt": {
          "mark": 255
        }
      },
      "mux": {
        "enabled": false
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {},
      "streamSettings": {
        "sockopt": {
          "mark": 255
        }
      }
    },
    {
      "tag": "adblock",
      "protocol" : "blackhole",
      "settings": {},
      "streamSettings": {
        "sockopt": {
          "mark": 255
        }
      }
    },
    {
      "protocol": "dns",
      "tag": "dns-out"
    }
  ],
    "dns": {
      "hosts": {
    "geosite:qihoo360": "0.0.0.0"
    },
    "servers": [
      "8.8.4.4",
      "1.1.1.1",
      {
        "address": "114.114.114.114",
        "port": 53,
        "domains": ["geosite:cn","ntp.org"]
      }
    ]
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "inboundTag": ["dns-in"],
        "outboundTag": "dns-out"
      },
      {                                                                   
        "type": "field",                                                  
        "domain": ["geosite:qihoo360"],                                   
        "outboundTag": "adblock"                                          
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "ip": ["geoip:private"]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "ip": ["geoip:cn"]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "domain": ["geosite:cn"]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "protocol": ["bittorrent"]
      }
    ]
  }
}
EOF
}
##########Remove Trojan-Gfw##########
uninstall(){
  cd
  systemctl stop trojan || true
  systemctl disable trojan || true
  rm -rf /usr/local/etc/trojan/* || true
  rm -rf /etc/trojan/* || true
  rm -rf /etc/systemd/system/trojan* || true
  rm -rf ~/.acme.sh/$domain || true
  systemctl stop v2ray  || true
  systemctl disable v2ray || true
  systemctl daemon-reload || true
  wget https://install.direct/go.sh -q
  sudo bash go.sh --remove
  rm go.sh
  systemctl stop nginx || true
  systemctl disable nginx || true
    if [[ $dist = centos ]]; then
    yum remove nginx dnsmasq -y || true
    else
    apt purge nginx dnsmasq -p -y || true
    rm -rf /etc/apt/sources.list.d/nginx.list
  fi
  sudo ~/.acme.sh/acme.sh --uninstall
}
##########Check for update############
checkupdate(){
  cd
  if [[ -f /usr/bin/v2ray/v2ray ]]; then
    wget https://install.direct/go.sh -q
    sudo bash go.sh
    rm go.sh
  fi
  if [[ -f /usr/local/bin/trojan ]]; then
    bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
  fi
}
###########Trojan share link########
trojanlink(){
  cd
  colorEcho ${INFO} "你的 Trojan-Gfw 分享链接(Share Link)1 is"
  colorEcho ${LINK} "trojan://$password1@$domain:443"
  colorEcho ${INFO} "你的 Trojan-Gfw 分享链接(Share Link)2 is"
  colorEcho ${LINK} "trojan://$password2@$domain:443"
if [[ $dist = centos ]]
then
colorEcho ${ERROR} "QR generate Fail ! Because your os does not support python3-qrcode,Please consider change your os!"
elif [[ $(lsb_release -cs) = xenial ]] || [[ $(lsb_release -cs) = trusty ]] || [[ $(lsb_release -cs) = jessie ]]
then
colorEcho ${ERROR} "QR generate Fail ! Because your os does not support python3-qrcode,Please consider change your os!"
else
  wget https://github.com/trojan-gfw/trojan-url/raw/master/trojan-url.py -q
  chmod +x trojan-url.py
  #./trojan-url.py -i /etc/trojan/client.json
  ./trojan-url.py -q -i /etc/trojan/client1.json -o $password1.png || true
  ./trojan-url.py -q -i /etc/trojan/client2.json -o $password2.png || true
  cp $password1.png /usr/share/nginx/html/ || true
  cp $password2.png /usr/share/nginx/html/ || true
  colorEcho ${INFO} "请访问下面的链接获取Trojan-GFW 二维码(QR code) 1"
  colorEcho ${LINK} "https://$domain/$password1.png"
  colorEcho ${INFO} "请访问下面的链接获取Trojan-GFW 二维码(QR code) 2"
  colorEcho ${LINK} "https://$domain/$password2.png"
  rm -rf trojan-url.py
  rm -rf $password1.png || true
  rm -rf $password2.png || true
fi
colorEcho ${INFO} "https://github.com/trojan-gfw/trojan/wiki/Mobile-Platforms"
colorEcho ${INFO} "https://github.com/trojan-gfw/trojan/releases/latest"
}
########V2ray share link############
v2raylink(){
  if [[ $install_v2ray = 1 ]]; then
    if [[ $install_ss = 1 ]]; then
    :
    else
  echo
  wget https://github.com/boypt/vmess2json/raw/master/json2vmess.py -q
  chmod +x json2vmess.py
  touch /etc/v2ray/$uuid.txt
  v2link=$(./json2vmess.py --addr $domain --filter ws --amend port:443 --amend tls:tls /etc/v2ray/config.json)  || true
    cat > "/etc/v2ray/$uuid.txt" << EOF
$v2link
EOF
  cp /etc/v2ray/$uuid.txt /usr/share/nginx/html/
  colorEcho ${INFO} "你的V2ray分享链接(Your V2ray Share Link)"
  cat /etc/v2ray/$uuid.txt
  colorEcho ${INFO} "请访问下面的链接(Link Below)获取你的V2ray分享链接"
  colorEcho ${LINK} "https://$domain/$uuid.txt"
  rm -rf json2vmess.py
  colorEcho ${INFO} "Please manually run cat /etc/v2ray/$uuid.txt to show share link again!"      
  fi
fi
}
##########SS Link###########
sslink(){
    if [[ $install_ss = 1 ]]; then
    echo
    colorEcho ${INFO} "你的SS信息(Your Shadowsocks Information)"
    colorEcho ${LINK} "$sspasswd@https://$domain/$sspath"
  fi
    if [[ $install_qbt = 1 ]]; then
    echo
    colorEcho ${INFO} "你的Qbittorrent信息(Your Qbittorrent Information)"
    colorEcho ${LINK} "https://$domain$qbtpath username admin password adminadmin"
  fi
}
##################################
timesync(){
  timedatectl set-timezone Asia/Hong_Kong || true
  timedatectl set-ntp on || true
  if [[ $dist = centos ]]; then
    :
    else
      ntpdate -qu 1.hk.pool.ntp.org || true
  fi
}
##################################
clear
function advancedMenu() {
    ADVSEL=$(whiptail --title "Trojan-Gfw Script Menu" --menu --nocancel "Choose an option RTFM: https://www.johnrosen1.com/trojan/" 25 78 16 \
        "1" "安裝(Install Trojan-GFW NGINX and other optional software)" \
        "2" "更新(Update  Trojan-GFW V2ray and Shadowsocks)" \
        "3" "卸載(Uninstall Everything)" \
        "4" "退出(Quit)" 3>&1 1>&2 2>&3)
    case $ADVSEL in
        1)
        cd
        clear
        userinput
        clear
        installdependency
        clear
        openfirewall
        clear
        issuecert
        clear
        nginxtrojan || true
        clear
        changepasswd || true
        bootstart
        clear
        timesync || true
        clear
        trojanclient || true
        trojanlink || true
        v2raylink || true
        sslink || true
        tcp-bbr || true
        start
        whiptail --title "Install Success" --msgbox "安装成功，享受吧！(Install Success! Enjoy it ! )多行不義必自斃，子姑待之。RTFM: https://www.johnrosen1.com/trojan/" 8 78
        ;;
        2)
        cd
        checkupdate
        colorEcho ${SUCCESS} "RTFM: https://www.johnrosen1.com/trojan/"
        ;;
        3)
        cd
        uninstall
        colorEcho ${SUCCESS} "Remove complete"
        ;;
        4)
        exit
        whiptail --title "脚本已退出" --msgbox "脚本已退出(Bash Exited) RTFM: https://www.johnrosen1.com/trojan/" 8 78
        ;;
    esac
}
echo "zh_TW.UTF-8 UTF-8" > /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
echo 'LANG="zh_TW.UTF-8"'>/etc/default/locale
export LANG="zh_TW.UTF-8"
export LC_ALL="zh_TW.UTF-8"
#export LANG=C.UTF-8 || true
#export LANGUAGE=C.UTF-8 || true
osdist || true
advancedMenu
echo "Program terminated."
