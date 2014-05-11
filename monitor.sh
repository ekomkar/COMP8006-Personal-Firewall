#!/bin/bash

#
#Author: Jivanjot S. Brar | A00774427
#Date: 01.25.2014
#

while true
do
	clear
	iptables -n -v -x -L www-ssh-traffic
	iptables -n -v -x -L noness-traffic 
	iptables -n -v -x -L traffic-in 
	iptables -n -v -x -L traffic-out
	iptables -n -v -x -L INPUT
	iptables -n -v -x -L OUTPUT
	sleep 1
	echo '[-------------------------------MONITORING-------------------------------]'
done
