#!/bin/bash
#
###########
# unblock-proxy.sh ver. 0.2.1 beta for Linux 
# ---------------------------------
# This script helps to traverse geoblocking like in hulu, netflix, zattoo etc 
# You can choose your favorite proxy engine, to get the best results
# There are 2 Main Modes: Tranparent Route Mode or SmartDNS Proxy
# Also there is a tiny proxy-checker included.
# 
# Have fun and Happy watching unblocked globally stuff! :)
# 
#
# Copyright (C) 2020 - by suuhm - suuhmer@coldwareveryday.com
#
# GNU General Public License v2.0
# -------------------------------
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
###########

_PROG=${0##*/}
_COMMAND_MODE="$1"
_REGEX="(-v|-h|-R|-C|--help|--version|--reset|--proxycheck)"
_MMTP=${1%%-*} #left of "-" must be _c_m

_BASE_DIR=/opt/unblock-proxy.sh/
_CONF_R=${_BASE_D%un*} #/opt/

_SNIPROXY_CONF=${_BASE_DIR}configs/sniproxy.conf
_DNS_CONF=${_BASE_DIR}configs/dnsmasq.conf
_TOR_CONF=${_BASE_DIR}configs/torrc
_SQUID_CONF=${_BASE_DIR}configs/squid.conf
_REDSOCKS_CONF=${_BASE_DIR}configs/redsocks.conf
_PCHAINS_CONF=${_BASE_DIR}configs/proxychains.conf

_BL_FILE=${_BASE_DIR}domains.lst
_PROXY_FILE=${_BASE_DIR}proxies.lst

_PIP=0
_PPORT=0
_PPROTO=0
_SSH_SOCKS=0

OIF=enp0s3
IIF=enp0s3

_usage()
{
    echo "Usage: $_PROG main-mode proxy-engine [options]>   
  
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
    -R, --reset             Resets all the IPTABLES and MASQ Entries.
    -C, --proxycheck        Just scans/checks the Proxies in ($_PROXY_FILE).
    
    -d, --debug             Show debug-verbose messages into the system log.
    -v, --version           Prints script-version.
    -h, --help              Print this help message.

    " 
}

_version()
{   
    echo -e "\n\e[1m\e[40m\e[94m   __  __ _   __ ____   __    ____   ______ __ __        ____   ____   ____  _  ____  __ "
    echo -e "  / / / // | / // __ ) / /   / __ \ / ____// //_/       / __ \ / __ \ / __ \| |/ /\ \/ / " 
    echo -e " / / / //  |/ // __  |/ /   / / / // /    / ,<  ____»_ / /_/ // /_/ // / / /|   /  \  /  " 
    echo -e "/ /_/ // /|  // /_/ // /___/ /_/ // /___ / /| |/_««__// ____// _, _// /_/ //   |   / /\e[5m\e[25m   "
    echo -e "\____//_/ |_//_____//_____/\____/ \____//_/ |_|      /_/    /_/ |_| \____//_/|_|  /_(\e[5m»)\e[25m  "
    echo -e "                                                                                         "
    echo -e "\e[39m\e[49m                                                                               "
        echo -e "\tUNBLOCK-PROXY.SH Ver. 0.2.1 for Linux"
        echo -e "\tCopyright 2020 - by suuhm - suuhmer@coldwareveryday.com"
        echo -e "\tThe Swiss Army knife to avoid geoblocking in VoD and censorship!\n\e[0m"  
}

_run_tor()
{
    BIN_CHK=$(command -v tor)
      
    if [[ $BIN_CHK ]]; then
        $BIN_CHK -f "$_TOR_CONF"
    else
        echo "[!!] Command $BIN_CHK not found!"
        echo "Try to search/install like: apt-get install $BIN_CHK"
        exit 111
    fi
}

_run_squid()
{
    PATH=$PATH:/usr/local/squid/sbin/:/usr/local/squid/bin/ 
    BIN_CHK=$(command -v squid)
      
    if [[ $BIN_CHK ]]; then
        $BIN_CHK -f $_SQUID_CONF
        squid -v | grep -E "with-openssl|enable-ssl-crtd"
        if [[ $? == 1 ]]; then 
            echo "Need to compiled with with-openssl and enable-ssl-crtd!"
            exit 122
        fi
    else
        echo "[!!] Command $BIN_CHK not found!"
        echo "Try to search/install like: apt-get install $BIN_CHK"
        exit 112
    fi
}

_run_privoxy()
{
    BIN_CHK=$(command -v privoxy)
      
    if [[ $BIN_CHK ]]; then
        $BIN_CHK $_PRIVOXY_CONF
    else
        echo "[!!] Command $BIN_CHK not found!"
        echo "Try to search/install like: apt-get install $BIN_CHK"
        exit 113
    fi
}

_run_redsocks()
{
    BIN_CHK=$(command -v redsocks)
      
    if [[ $BIN_CHK ]]; then
        $BIN_CHK -c $_REDSOCKS_CONF
    else
        echo "[!!] Command $BIN_CHK not found!"
        echo "Try to search/install like: apt-get install $BIN_CHK"
        exit 114
    fi
}

_run_proxychains()
{
    BIN_CHKCH=$(command -v proxychains)
    BIN_CHKSNI=$(command -v sniproxy)
    PCSNIC="sniproxy -c ${_SNIPROXY_CONF}"
      
    if [[ $BIN_CHKCH && $BIN_CHKSNI && $_PCPARA =~ SNIT|SDNS && -z $_DEBUG_VERBOSE ]]; then
        cp -a $_PCHAINS_CONF ./
        sed 's/#qui/qui/g' -i ./proxychains.conf
        $BIN_CHKCH ${PCSNIC} -f &
    elif [[ $BIN_CHKCH && $BIN_CHKSNI && $_PCPARA =~ SNIT|SDNS && $_DEBUG_VERBOSE > 0 ]]; then
        cp -a $_PCHAINS_CONF ./
        $BIN_CHKCH ${PCSNIC} -f
    else
        echo "[!!] Commands $BIN_CHKCH and $BIN_CHKSNI not found!"
        echo "Try to search/install like: apt-get install $BIN_CHKCH $BIN_CHKSNI"
        exit 115
    fi
}

_run_sniproxy()
{
    BIN_CHK=$(command -v sniproxy)
      
    if [[ $BIN_CHK && $_PCPARA == "SDNS" ]]; then
        $BIN_CHK -c ${_SNIPROXY_CONF}
    else
        echo "[!!] Command $BIN_CHK not found!"
        echo "Try to search/install like: apt-get install $BIN_CHK"
        exit 116
    fi
}

_run_dnsmasq()
{
    BIN_CHK=$(command -v dnsmasq)
      
    if [[ $BIN_CHK ]]; then
        $BIN_CHK -C $_DNS_CONF
    else
        echo "[!!] Command $BIN_CHK not found!"
        echo "Try to search/install like: apt-get install $BIN_CHK"
        exit 117
    fi
}

_get_blacklist()
{
    if [[ -e $_BL_FILE ]]; then
        BL_ARRAY=`grep -v -E "^#|^$" $_BL_FILE`
        echo -e "\n\e[1m\e[94m[*] Blacklist found at $_BL_FILE\e[39m\e[0m"
    else
        echo "[!!] No Blacklist found at $_BL_FILE, exit now.."
        exit 166
    fi
}

_get_interfaces()
{
    IF_T=$(ip route | grep def | awk '{print $5}')
    if [[ $IF_T ]]; then
        IIF=$IF_T 
        OIF=$IF_T
        #GET IP ADDRESS
        IPADDR=$(ip addr show dev $OIF | grep global | awk '{print $2}' | cut -d '/' -f 1)
        echo -e "\e[1m\e[94m[*] Setting up iface IN -> ($IIF) and OUT -> ($OIF) <==> ($IPADDR)\e[39m\e[0m"
    else
        echo "[!!] Network_error: No Interface found"
        exit 167    
    fi        
}

_get_proxy()
{
    _counter=0
    
    if [[ -e $_PROXY_FILE && $_SSH_SOCKS < 1 ]]; then
        PROXY_ARRAY=`grep -v -E "^#|^$" $_PROXY_FILE`
    
        while read PROX; do
            sleep 2
            _PIP=`awk '{print $2}' <<<$PROX`
            _PPORT=`awk '{print $3}' <<<$PROX`
            _PPROTO=`awk '{print $1}' <<<$PROX`
            #$(nc -w 7 -z -v $_PIP $_PPORT 2>&1 | grep open)
            printf "[~ $((_counter=$_counter+1))] Testing Proxy: $_PIP:$_PPORT $_PPROTO"
            curl -m 32 --connect-timeout 70 -x $_PPROTO://$_PIP:$_PPORT -fsL https://proxycheck.coldwareveryday.com >/dev/null 2>&1
            
            if [[ $? == 0 ]]; then
                printf " \e[32m[seems to work :)]\n[*] FOUND! ($_PIP)\n\e[39m\e[0m"
                CONT=1; sleep 2
                [ -z $1 ] && break
            else
                printf " \e[31m[bad proxy :(]\n\e[39m\e[0m"
                sleep 2
            fi
        done <<< "$PROXY_ARRAY"
        
        if [[ $CONT < 1 ]]; then
            echo "[!!] No Proxies found or working..."
            exit 169
        fi
        
    elif [[ $_SSH_SOCKS > 0 ]]; then
        _set_ssh_socks
        _PIP="127.0.0.1"
        _PPORT="2228"
        _PPROTO="socks5"
        _PROXY_FILE="$_PPROTO $_PIP $_PPORT"
    else
        echo "[!!] No Domains-file found at $_PROXY_FILE, exit now.."
        exit 168
    fi
}

_set_ssh_socks()
{
    echo -n "> Enter your SSH-Host and press [ENTER]: "
    read SSH_HOST
    echo -n "> Enter your SSH-Port and press [ENTER]: "
    read SSH_PORT
    echo -n "> Enter your SSH-Username and press [ENTER]: "
    read SSH_USER
    
    if [[ -z $SSH_HOST || -z $SSH_PORT || -z $SSH_USER ]]; then
        echo "SSH Host, Port or User not set, quitting.."
        exit 170
    else
        ssh -D *:2228 -q -C -N -f -l $SSH_USER -p $SSH_PORT $SSH_HOST
    fi  
}

_kill_ngines()
{
    for PID in tor squid privoxy redsocks proxychains sniproxy dnsmasq; do
        TP=$(ps aux | grep -E "\ $PID|\/$PID" | grep -v grep | awk '{print $2}')
        printf "\n[X] Killing process: $PID: "
        for I in $TP; do
            printf ">> kill pid -> $I "
            [[ $I != $$ ]] && kill $I >/dev/null 2>&1 
            sleep 2
        done
    done
    echo ""
}

_init_iptables()
{
    echo -e "\n\e[1m\e[94m[*] Setting up IP-Tables...\e[39m\e[0m"
    echo "1" > /proc/sys/net/ipv4/ip_forward
    iptables -t nat -A POSTROUTING -o $OIF -j MASQUERADE
    iptables -I INPUT -i $IIF -p udp -m multiport --dports 53,5533 -j ACCEPT
    iptables -I INPUT -i $IIF -p tcp -m multiport --dports 53,22,80,443 -j ACCEPT
    iptables -A FORWARD -i $IIF -o $OIF -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i $IIF -o $OIF -j ACCEPT
}
    
_flush_iptables() 
{
    echo -e "\n\e[1m\e[94m[*] Re-Setting all IPTable-Entries...\e[39m\e[0m"
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    echo "0" > /proc/sys/net/ipv4/ip_forward
    #rm -rf ${TMP_CONF}
    [ -z $1 ] && exit 0
}

_set_transpa()
{
    if [[ $_PROX_ENGINE == "proxychains" ]]; then
        IJUMP="REDIRECT"
        _PCPARA="SNIT"
    fi
    
    ## SETTING TABLES
    iptables -t nat -I OUTPUT -p tcp -m owner --uid-owner $(whoami) -j RETURN
        
    for DOM in $BL_ARRAY; do
        echo -e " -> Setting up Hostname: $DOM"
        #DNS REDIRECT BY TOR NETWORK ONLY YET!
        #iptables -t nat -A PREROUTING -i $IIF -p udp -m multiport -d $DOM --dports 53,5533 -j $IJUMP --to-ports 5533
        iptables -t nat -A PREROUTING -i $IIF -p tcp -m multiport -d $DOM --dports 80,443 -j $IJUMP
        #ROUTE ALL TRAFFIC WITH SYN FLAG
        #iptables -t nat -A PREROUTING -i $IIF -p tcp --syn -j REDIRECT --to-ports 4433  
    done        
}

_set_smart_dns()
{
    echo -e "\n\e[1m\e[94m[*] Setup SMART DNS PROXY\e[39m\e[0m"
    for DOM in $BL_ARRAY; do
        echo -e "-> Setting up Hostname: $DOM"
        echo "address=/$DOM/$IPADDR" >> $_DNS_CONF      
    done
    
    if [[ $_PROX_ENGINE != "proxychains" ]]; then       
        _PCPARA="SDNS" && _run_sniproxy     
    else
        _PCPARA="SDNS"
    fi
    
    ## SETTING TABLES
    iptables -t nat -I OUTPUT -p tcp -m owner --uid-owner $(whoami) -j RETURN
    iptables -t nat -A OUTPUT -p tcp -m multiport --dports 80,443 -j $IJUMP       
}

_set_ngin_conf()
{
    TMP_CONF=/tmp/unblock-proxy-conf
    mkdir -p $TMP_CONF && cp -ra ${_BASE_DIR}configs/* $TMP_CONF
    _SQUID_CONF=${TMP_CONF}/squid.conf
    _PRIVOXY_CONF=${TMP_CONF}/privoxy.conf
    _REDSOCKS_CONF=${TMP_CONF}/redsocks.conf
    _DNS_CONF=${TMP_CONF}/dnsmasq.conf
    _PCHAINS_CONF=${TMP_CONF}/proxychains.conf


    case "$_PROX_ENGINE" in                                            
            tor)                                   
                    #_run_tor; 
                    ## SET TABLES
                    IJUMP="REDIRECT --to-ports 4433"                       
                    ;;                                      
            squid)
                    _get_proxy          
                                
                    ## SET SSL CERTS
                    if [[ ! -d ${_BASE_DIR}certs ]]; then
                        mkdir ${_BASE_DIR}certs
                        cd ${_BASE_DIR}
                        . cert-creator.sh
                    fi
                    
                    if [[ $_PPROTO =~ ^s.+|^S.+ ]]; then    
                        sed "s/_SIP_ parent _SPORT_/127.0.0.1 parent 8888/g" -i $_SQUID_CONF
                        sed "s/\_SIP\_/$_PIP/g" -i $_PRIVOXY_CONF
                        sed "s/\_SPORT\_/$_PPORT/g" -i $_PRIVOXY_CONF
                        sed "s/\_SPROTO\_/$_PPROTO/g" -i $_PRIVOXY_CONF 
                        _run_privoxy #to use some socks here
                    else
                        sed "s/\_SIP\_/$_PIP/g" -i $_SQUID_CONF
                        sed "s/\_SPORT\_/$_PPORT/g" -i $_SQUID_CONF
                    fi   
                    
                    ## SET TABLES
                    IJUMP="REDIRECT --to-ports 4433"                       
                    ;;                                      
            redsocks)  
                    _get_proxy                                     
                    sed "s/\_SIP\_/$_PIP/g" -i $_REDSOCKS_CONF
                    sed "s/\_SPORT\_/$_PPORT/g" -i $_REDSOCKS_CONF
                    [[ $_PPROTO =~ ^S ]] && _PPROTO=`sed 's/^S/s/g' <<<$_PPROTO`
                    [[ $_PPROTO =~ ^h|^H ]] && _PPROTO="http-connect"
                    sed "s/\_SPROTO\_/$_PPROTO/g" -i $_REDSOCKS_CONF   
                    
                    ## SET TABLES:
                    IJUMP="REDSOCKS"
                    iptables -t nat -N REDSOCKS
                    iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
                    iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
                    iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
                    iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
                    iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
                    iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
                    iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
                    iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
                    iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 4433                                                     
                    ;;                                      
            proxychains)
                    if [[ $_SSH_SOCKS > 0 ]]; then 
                        _get_proxy                                     
                        echo $_PROXY_FILE >> $_PCHAINS_CONF
                    else
                        grep -vE '^#' $_PROXY_FILE | sed '/^$/d' >> $_PCHAINS_CONF  
                    fi
                    
                    ## SET TABLES: 
                    IJUMP="REDIRECT"                                                             
                    ;;                                                                         
            *)
                    echo -e "BAD OPTION - PLS CHOOSE UR WARRIOR\n"                                                                  
                    _usage                                  
                    exit 123                                
                    ;;                                      
    esac   
}

_start_ngin()
{
    echo -e "\n\e[1m\e[94m[*] Now starting Engine: ($_PROX_ENGINE).\e[39m\e[0m\e[0m"
    
    case "$_PROX_ENGINE" in                                            
            tor)                                   
                    _run_tor                       
                    ;;                                      
            squid)                                      
                    _run_squid                          
                    ;;                                      
            redsocks)                                       
                    _run_redsocks                                                        
                    ;;                                      
            proxychains)                                     
                    _run_proxychains                                                   
                    ;;                                                                         
            *)
                    echo "BAD OPTION - PLS CHOOSE UR WARRIOR"                                                                  
                    _usage                                  
                    exit 124                                
                    ;;                                      
    esac                                                        
}

## M A I N  -  F U N C ##

if [[ "$#" == '0' ]]; then
    echo "Argument list empty"
    exit 11
fi

if [[ "$_MMTP" != '' ]]; then
    shift 1
else
    if ! [[ $_COMMAND_MODE =~ $_REGEX ]]; then 
        _usage ; exit 13 
    fi
fi

GETOPT=`getopt -T`
if [[ $? != 4 && $? != 1 ]]; then
    echo "Error 111: GETOPT missing"
    exit 14
fi

_getopt=$(getopt -o tsrpio::SRCvhd --long tor,squid,redsocks,proxychains,in-if::,out-if::ssh-socks,reset,proxycheck,version,help,debug -n $_PROG -- "$@")
if [[ $? != 0 ]] ; then 
    echo "bad command line options" >&2 ; exit 15 ; 
fi

eval set -- ${_getopt}

while true; do
    case "$1" in
            -v|--version)
                    _version; exit 0 
                    ;;
            -h|--help)
                    _usage; exit 0 
                    ;;
            -t|--tor)
                    _PROX_ENGINE="tor"
                    shift
                    ;;
            -s|--squid)
                    _PROX_ENGINE="squid"
                    shift 
                    continue
                    ;;
            -r|--redsocks)
                    _PROX_ENGINE="redsocks"
                    shift
                    continue 
                    ;;
            -p|--proxychains)
                    _PROX_ENGINE="proxychains"  
                    shift
                    ;;
            -i|--in-if)
                    if [[ -z "$2" ]]; then
                        echo -e "Missing device\n" ; _usage
                        exit 16;
                    else
                        IIF=$2; IF_MSET=1
                        shift 2;
                    fi
                    continue 
                    ;;
            -o|--out-if)
                    if [[ -z "$2" ]]; then
                        echo -e "Missing device\n" ; _usage
                        exit 17;
                    else
                        OIF=$2; IF_MSET=1
                        shift 2;
                    fi
                    continue 
                    ;;
            -S|--ssh-socks)
                    _SSH_SOCKS=1;
                    shift  
                    ;;
            -R|--reset)
                    _flush_iptables; break  
                    ;;
            -C|--proxycheck)
                    _get_proxy 2; 
                    exit 0  
                    ;;
            -d|--debug)
                    _DEBUG_VERBOSE=1
                    shift
                    ;;
            --)
                    shift; break 
                    ;;
            *)
                    echo "BAD OPTION $1"
                    _usage
                    exit 23
                    ;;
    esac
done

_version; sleep 3

if [[ -z $IF_MSET ]]; then
    _get_interfaces
else
    ## GET IP ADDRESS
    IPADDR=$(ip addr show dev $OIF | grep global | awk '{print $2}' | cut -d '/' -f 1)
    echo -e "\n\e[1m\e[94m[*] Setting up iface IN -> ($IIF) and OUT -> ($OIF) <=> ($IPADDR)\e[39m\e[0m" 
fi

## KILL, KILL, DIE, DIE...
_kill_ngines
_flush_iptables -xinit

if [[ $_COMMAND_MODE == 'transparent' ]]; then
    _init_iptables 
    _get_blacklist
    _set_ngin_conf
    _set_transpa    
    _start_ngin
    
    echo -e "\n\a\e[1m\e[94m
    ---------------------------------------------------------
       [*] All Done. Now set ur gateway to: $IPADDR
    ---------------------------------------------------------
    \e[39m\e[0m\n\r"
    
elif [[ $_COMMAND_MODE == 'dns' ]]; then
    _get_blacklist
    _set_ngin_conf
    _set_smart_dns
    _run_dnsmasq    
    _start_ngin
    
    echo -e "\n\a\e[1m\e[94m
    ---------------------------------------------------------
       [*] All Done. Now set ur First-DNS to: $IPADDR
    ---------------------------------------------------------
    \e[39m\e[0m\n\r"
fi

## SET OPTIONAL SYSLOG DEBUGGING
if [[ $_DEBUG_VERBOSE > 0 && -z $PCSNIC ]]; then
    echo -e "\n\e[1m\e[94m[*] Starting Debugging Mode in 10 seconds:\n\r\e[39m\e[0m"    
    sleep 10
    echo -e -n "\a\a"
    tail -f -n 70 /var/log/syslog | grep -iE "$_PROX_ENGINE\["
fi

exit 0;
