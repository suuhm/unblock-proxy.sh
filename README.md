![Thumb](/img/unblock-version.gif)
### A "Swiss Army proxy-knife" to avoid geoblocking in Video on Demand and censorship in your whole network!

# Background - Why this script?
There are many devices in my network, which do not allow to set a proxy manually, I have always had to prepare my router or a computer, which was a lot of time and configuration effort.

With this script, I have the possibility to offer a proxy in my whole network for desired domains. Even if DNS or transparent router.
Furthermore I can choose which proxy engine should be used. 

It couldn't be easier!

This Script uses a List of (Free)-Proxies and Domains that allows you to set up unrestricted access to streaming content on your smart-TV, Kodi, Emby Mediaserver and other devices to watch your media region-free like:

    Zattoo
    HULU (US region)
    Netflix Originals
    Amazon Prime
    BBC iPlayer
    Youtube
    Discovery
    Disney Channel Plus
    Fox Now / Sports Go / News / Showtime
    HBO Now
    
    And many, many many more!

#### It's not a VPN! And this will save your bandwidth massively

# Features
#### Main Modes:
- Router (transparent) Mode (This can be use on a OpenWRT Route or something similar)
- Smart (DNS) Mode (Set this to any device where you can set a DNS Server Setting)
#### Proxy Engines:
- Tor
- Squid (incl. Certcreator for SSL-Bump Functionality)
- Redsocks
- Proxychains

![Thumb](/img/unblock-dns-redsocks.gif)

#### Proxyserver Scanner
- Socks4, Socks5
- HTTP/S

![Thumb](/img/unblock-check.gif)

#### SSH-Socks (for your own Socks-Proxy connection via SSH)

#### Web-Backend (beta Version! Requires >=PHP 5.4.0 - For smart web-adminstration)

![Thumb](/img/web-backend.PNG)

# How to use the script

## !!!THIS VERSION IS BETA AND ONLY TESTED ON DEBIAN/UBUNTU SYSTEMS! SO PLEASE WRITE AN ISSUE IF YOU HAVE SOME TROUBLE HERE!!!

### 1. Clone and install the script (Minimal Requirements)
```
sudo apt install iproute2 iptables git sniproxy dnsmasq 
# If you wish to use the integrated Web-Server
# apt install php

git clone https://github.com/suuhm/unblock-proxy.sh /opt/unblock-proxy.sh
chmod +x /opt/unblock-proxy.sh/unblock-proxy.sh && ln -s /opt/unblock-proxy.sh/unblock-proxy.sh /usr/bin/
```

### 2. Depends on engine you want to use:
#### - Tor
```
sudo apt install tor
```
#### - Squid
```
VER=4.13
sudo apt install build-essential openssl libssl-dev pkg-config privoxy

mkdir -p ~/squid4 && cd ~/squid4
wget http://www.squid-cache.org/Versions/v4/squid-$VER.tar.gz
tar -xzvf squid-$VER.tar.gz && cd squid-$VER

echo "Start Compiling:" ; sleep 1
./configure --with-default-user=proxy --with-openssl --enable-ssl-crtd
make && sudo make install

chown proxy:proxy -R /usr/local/squid/
# Initial crt database (For problems use 10M or more)
/usr/local/squid/libexec/security_file_certgen -c -s /usr/local/squid/var/cache/squid/ssl_db -M 4MB
```
#### - redsocks
```
sudo apt install redsocks
```
  ###### Or Compiling...
```
sudo apt install libevent-dev build-essential
git clone https://github.com/darkk/redsocks ~/redsocks
cd ~/redsocks && make 
sudo ln -s ~/redsocks/redsocks /usr/bin/ 
```
#### - proxychains
```
sudo apt install proxychains
```

### 3. Put your wished Proxy in the proxies.lst file. 
#### (Please google for free proxy Server)

### 4. Put your wished Domain in the domains.lst file. 
#### (There're already a few useful ones inside)

### 5. Run the unblock-proxy.sh (See examples below) and Have fun! 


# Options 
```
Usage: unblock-proxy.sh main-mode proxy-engine [options]>   
  
  main-mode:  
	       
	transparent             Activates the transparent routing-gw. 
	dns                     Activates the DNS Smart-Proxy.    
	                    
  proxy engines:  
	
	-t, --tor               Activates the TOR Engine.
	-s, --squid             Activates the Squid Engine.
	-r, --redsocks          Activates the RedSocks Engine.
	-p, --proxychains       Activates the proxychains Engine.
	
  options:
	
	-i, --in-if=            Sets the in-interface Device.
	-o, --out-if=           Sets the out-interface Device.
	-S, --ssh-socks         Set own Server as Parent Socks-Proxy over SSH-tunnel. 
                                (Can't be use with tor-Engine!)
	-w, --web-admin         Starts a small Webserver-Backend at Port 8383
                                (Requires php framework >=5.4!)
	-R, --reset             Resets all the IPTABLES and MASQ Entries.
	-C, --proxycheck        Just scans/checks the Proxies in (/opt/unblock-proxy/proxies.lst).
	
	-d, --debug             Show debug-verbose messages into the system log.
	-v, --version           Prints script-version.
	-h, --help              Print this help message.
  
```

# Examples
#### Using Transparent Router-Mode with Tor Engine
```bash
unblock-proxy.sh transparent --tor
```

#### Using Transparent Router-Mode with Redsocks Engine and pull off Debug-infos
```
unblock-proxy.sh transparent --redsocks --debug
```

#### Using Transparent Router-Mode with Redsocks Engine and pull off Debug-infos (Same but: Short Parameters)
```
unblock-proxy.sh transparent -r -d
```

#### Using Smart DNS Mode with squid Engine and pull off Debug-infos. Also start the Web-Backend Server
```
unblock-proxy.sh dns --squid --debug --web-admin
```

#### Using Smart DNS Mode with squid Engine, Using SSH-Socks Proxy and pull off Debug-infos
```
unblock-proxy.sh dns -s --ssh-socks --debug
```

#### Using Smart DNS Mode with proxychains Engine, using specific Network-Card and pull off Debug-infos
```
unblock-proxy.sh dns --proxychains --in-if=eth2 -o wlan0 -d
```

#### Resetting and Check your Proxylist
```
unblock-proxy.sh -R

unblock-proxy.sh -C
```

# Report Bugs!
This Version is a pure beta version!
When you find bugs, please let me know.

Thanks.

# -
	This program is free software; you can redistribute it and/or modify it under
	the terms of the GNU General Public License as published by the Free Software
	Foundation

	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
	FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
	details.

