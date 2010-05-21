#!/bin/bash
	ping -c 1 -t 1 $1 2>&1 >/dev/null
	arp -n -i en0 $1
