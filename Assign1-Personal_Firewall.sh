#!/bin/bash

#
#Author: Jivanjot S. Brar | A00774427
#Date: 01.25.2014
#

############################# VARIABLES ###########################

#INTERFACE='em1'
#SERVER='192.168.0.22'
INTERFACE='wlp2s0'
SERVER='142.232.146.143'
PORTS_NOT_ALLOWED='0:1023'

clear

# 1. Delete All Existing rules
iptables -F
# 2. Delete All User Defined Chains
iptables -X
# 3. Default Policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

############################# User Defined Chains ######################
iptables -N www-ssh-traffic
iptables -N noness-traffic
iptables -N traffic-in
iptables -N traffic-out
iptables -A www-ssh-traffic
iptables -A noness-traffic

############################# FIREWALL RULES ###########################

# 4. DROPING PORT 0 TRAFFIC
# TCP 
iptables -A traffic-out -p tcp --dport 0 -j DROP
iptables -A traffic-in -p tcp --sport 0 -j DROP
iptables -A traffic-out -p tcp --sport 0 -j DROP
iptables -A traffic-in -p tcp --dport 0 -j DROP
#UDP
iptables -A traffic-out -p udp --dport 0 -j DROP
iptables -A traffic-in -p udp --sport 0 -j DROP
iptables -A traffic-out -p udp --sport 0 -j DROP
iptables -A traffic-in -p udp --dport 0 -j DROP

# 5. Allowing DNS Services
# TCP DNS
iptables -A traffic-out -p tcp --dport 53 -j ACCEPT
iptables -A traffic-in -p tcp --sport 53 -j ACCEPT
# UDP DNS
iptables -A traffic-out -p udp --dport 53 -j ACCEPT
iptables -A traffic-in -p udp --sport 53 -j ACCEPT

# 6. Allowing DHCP Services
iptables -A traffic-out -p udp --dport 67:68 -j ACCEPT
iptables -A traffic-in -p udp --sport 67:68 -j ACCEPT

# 7. Allowing Inbound SSH 
iptables -A traffic-in -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A traffic-out -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# 8. Allowing Outbound SSH
iptables -A traffic-out -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A traffic-in -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# 9. Drop all Inbound traffic to port 80,443 from source port less than 1024
iptables -A traffic-in -p tcp --sport $PORTS_NOT_ALLOWED --dport 80 -j DROP
iptables -A traffic-in -p tcp --sport $PORTS_NOT_ALLOWED --dport 443 -j DROP

# 10. Allowing Inbound HTTP (port 80)
iptables -A traffic-in -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A traffic-out -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

# 11. Allowing Outbound HTTP (port 80)
iptables -A traffic-out -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A traffic-in -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

# 12. Allowing Inbound HTTPS (port 443)
iptables -A traffic-in -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A traffic-out -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# 13. Allowing Outbound HTTPS (port 443)
iptables -A traffic-out -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A traffic-in -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT


############################ IP ACCOUNTING  ############################

iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j www-ssh-traffic
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j www-ssh-traffic
iptables -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j www-ssh-traffic
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j www-ssh-traffic

iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j www-ssh-traffic
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j www-ssh-traffic
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j www-ssh-traffic
iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j www-ssh-traffic

iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j www-ssh-traffic
iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j www-ssh-traffic
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j www-ssh-traffic
iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j www-ssh-traffic

#####################  REDIRECT TO FIREWALL RULES  #####################

iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j traffic-in
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j traffic-out
iptables -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j traffic-out
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j traffic-in

iptables -A INPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j traffic-in
iptables -A OUTPUT -p tcp --sport 80 -m state --state ESTABLISHED -j traffic-out
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j traffic-out
iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j traffic-in

iptables -A INPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j traffic-in
iptables -A OUTPUT -p tcp --sport 443 -m state --state ESTABLISHED -j traffic-out
iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j traffic-out
iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j traffic-in

############################ IP ACCOUNTING  ############################

# Rest of the traffic
iptables -A INPUT -j noness-traffic
iptables -A OUTPUT -j noness-traffic

#####################  REDIRECT TO FIREWALL RULES  #####################

iptables -A INPUT -j traffic-in
iptables -A OUTPUT -j traffic-out


############################ END  ############################
echo ''
echo '###### FIREWALL RULES DEPLOYED ######'

chmod +x monitor.sh
./monitor.sh
