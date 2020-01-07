![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)
# Trojan-GFW Script (NO Centos7 Support!!!)
## This script will help you set up a [Trojan-GFW](https://github.com/trojan-gfw/trojan) server in an extremely fast way.
### Read The Fucking Manual: https://www.johnrosen1.com/trojan/ 

#### via wget
```
apt-get update && apt-get install sudo wget -y | yum install sudo wget -y
sudo bash -c "$(wget -O- https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"
```
#### or via curl
```
apt-get update && apt-get install sudo curl -y | yum install sudo curl -y
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"
```

### 中文GUI版本(main repository)
```
apt-get update && apt-get install sudo whiptail curl -y | yum install sudo newt curl -y
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojangui.sh)"
```
### [BBRPLUS](https://github.com/chiakge/Linux-NetSpeed) VERSION
```
apt-get update && apt-get install sudo whiptail curl -y | yum install sudo newt curl -y
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojangui%20-bbrplus.sh)"
```
### Shadowsocks Version (ws+tls+[V2ray-plugin](https://github.com/shadowsocks/v2ray-plugin))
```
apt-get update && apt-get install sudo whiptail curl -y | yum install sudo newt curl -y
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan-ss.sh)"
```
### [Qbittorrent](https://www.johnrosen1.com/qbt/) Version (No Centos Support)
```
apt-get update && apt-get install sudo whiptail curl -y | yum install sudo newt curl -y
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojangui-qbt.sh)"
```
#### Bash Features:

1. Auto install and config [Trojan-GFW](https://github.com/trojan-gfw/trojan) [NGINX](https://www.nginx.com/) [Dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) [V2ray](https://www.v2ray.com/index.html) [Shadowsocks](https://shadowsocks.org/en/index.html) and [Qbittorrent](https://www.qbittorrent.org/)
3. Auto issue renew [let's encrypt certificate](https://letsencrypt.org/) and **auto reload Trojan-GFW after renewal**
4. Auto OS Detect **Support [Centos](https://www.centos.org/) [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/)** (Centos not recommended !!!)
5. Auto domain resolve verification
6. Auto [iptables](https://en.wikipedia.org/wiki/Iptables)(includes ipv6) firewall config and iptables-persistent
7. Auto generate client config (includes both Trojan-GFW and V2ray )
8. Auto random vmess uuid generate
9. Auto [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks) enable ( **[TCP-BBR](https://github.com/google/bbr)** included)
10. Auto [Nginx Performance Optimization](https://www.johnrosen1.com/nginx1/)
11. Auto [Trojan-GFW ***trojan://*** share link and QR code generate](https://github.com/trojan-gfw/trojan-url)
12. Auto [V2ray ***vmess://*** share link generate](https://github.com/boypt/vmess2json)
13. Auto https 301 redirect without affecting certificate renew
14. Auto enable [HSTS header](https://securityheaders.com/)
15. Auto enable ***TLS1.3 ONLY***
16. Auto ***Random Html Template Choose***
17. Auto enable [***Full IPv6 Support***](https://en.wikipedia.org/wiki/IPv6)
18. Auto enable ***time sync***
19. Auto enable ***Fail Restart*** 
20. Auto [uninstall Aliyun Aegis](https://www.johnrosen1.com/ali-iso/)
21. Auto [shutdown and disable SElinux](https://support.plesk.com/hc/en-us/articles/213947705-How-to-disable-SELinux-on-a-server)
19. Support auto [***vmess or ss + tls + websocket + nginx*** config](https://guide.v2fly.org/advanced/wss_and_web.html)
20. Support custom websocket path and alterid
21. Support manually check for update include both Trojan-gfw and v2ray
22. Support manually force renew certificate
23. Support Full Uninstall

#### Friendly Reminder:
1. Please **[Purchase a domain](https://www.namesilo.com/?rid=685fb47qi)** and finish a dns resolve before running this bash script!
2. Please manually change system dns to frequently updated dns like [1.1.1.1](https://1.1.1.1/) instead of those who update slowly like aliyun lan dns !
```
echo "nameserver 1.1.1.1" > '/etc/resolv.conf'
```
3. Please ***choose option2 if you want to use v2ray or shadowsocks !***
5. Please do not use enter / in websocket option ,enter someting else like /secret !
6. For security reasons, system upgrade is not forced ,press [ENTER] to skip or manually enter y to upgrade system.
7. Trojan-GFW QR code generate will be skipped on os who do not support python3-qrcode!
8. Due to personal demands , Dnsmasq installation is not forced ,press [ENTER] to skip or manually enter y to install dnsmasq.
9. If "sudo command not found" , please manually install sudo from the command above !

#### [Telegram](https://telegram.org/) Channel And Group

### https://t.me/johnrosen1

### https://t.me/trojanscript

Attachment: **If you need more functions, please open a Github issue.**

## If you found it useful , please give a star ,thanks!

### VPS Recommendation (no personal aff included)

#### https://www.kamatera.com/

### Debug Guide

```
sudo systemctl status trojan
sudo systemctl status trojan6
sudo systemctl status nginx
sudo systemctl status v2ray
sudo systemctl status dnsmasq
sudo systemctl status qbittorrent
journalctl -e -u trojan.service
cat /var/log/v2ray/error.log
crontab -l
sudo ~/.acme.sh/acme.sh --cron
timedatectl
```
### Result Example
```
trojan://trojanscript@www.johnrosen.top:443
```
![Trojan-GFW QR code](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojanscript.png)



