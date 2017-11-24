#!/bin/bash
$"hostname"
a="hostname --all-ip-addresses"
$a
b="curl -s http://169.254.169.254/latest/meta-data/public-hostname"
$b
echo
c="curl -s http://169.254.169.254/latest/meta-data/instance-id"
$c
echo
d="curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//'"
$d
echo
e=$(curl -s http://169.254.169.254/latest/meta-data/mac)
f=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$e/vpc-id)
echo $f

