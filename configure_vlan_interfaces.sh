#!/bin/bash/
################################################################################
# Licensed to the Mosaic5G under one or more contributor license
# agreements. See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.
# The Mosaic5G licenses this file to You under the
# Apache License, Version 2.0  (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#  
#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
# -------------------------------------------------------------------------------
#   For more information about the Mosaic5G:
#       contact@mosaic-5g.io
#
#
################################################################################
# file 
# brief		Automation of configuring the vlan interfaces 
# author  	Mihai IDU

###################################
# colorful echos
###################################

black='\E[30m'
red='\E[31m'
green='\E[32m'
yellow='\E[33m'
blue='\E[1;34m'
magenta='\E[35m'
cyan='\E[36m'
white='\E[37m'
reset_color='\E[00m'
COLORIZE=1

cecho()  {
    # Color-echo
    # arg1 = message
    # arg2 = color
    local default_msg="No Message."
    message=${1:-$default_msg}
    color=${2:-$green}
    [ "$COLORIZE" = "1" ] && message="$color$message$reset_color"
    echo -e "$message"
    return
}

echo_error()   { cecho "$*" $red          ;}
echo_fatal()   { cecho "$*" $red; exit -1 ;}
echo_warning() { cecho "$*" $yellow       ;}
echo_success() { cecho "$*" $green        ;}
echo_info()    { cecho "$*" $blue         ;}

# check if the vlan software packages are installed on Ubuntu
function install_vlan {
	echo_info "Installing the vlan software dependencies"
	sudo apt-get install vlan -y
	echo_info "Load the vlan kernel module"
	sudo modprobe 8021q
	echo_info "Update all dependencies"
	sudo apt-get update -y
	echo_info "Make the configuration permanent"
	sudo su -c 'echo "8021q" >> /etc/modules'
}

function configure_interface {
	echo_info "Adding the vlan interface configuration"
	sudo su
	echo "auto enp0s31f6.$VLANID" >> /etc/network/interfaces
	echo "iface enp0s31f6.$VLANID inet static" >> /etc/network/interfaces
	echo "         address $VLANIPADDR" >> /etc/network/interfaces
	echo "         netmask $VLANNETMASK" >> /etc/network/interfaces
	echo "         gateway $VLANGW" >> /etc/network/interfaces
	echo "         network $VLANNETWORK" >> /etc/network/interfaces
	echo "         broadcast $VLANBRCST" >> /etc/network/interfaces
}


############################
# manage options and helps
###########################
function print_help() {
  echo_info '
This program installs the Mosaic5G.io software platforms from snaps
or build a custom platform from the source file.
You should have ubuntu 16.xx. Root password required.
Options
-h
   print this help
--clean-snaps
Usage:
- build_m5g -i -m : insatll all the sanps and run 
- build_m5g -i -j

'
}

# Reading the values from the keyboard

