#!/bin/bash

#sudo apt install git openssh-client ssh
sudo apt install -y lua5.3 lua5.1 build-essential gcc libx11-dev libxft-dev libxinerama-dev dbus-x11

CWD_PATH="$(pwd)"
git submodule update --init --recursive
cd $CWD_PATH/dwm
make clean install
cd $CWD_PATH/dmenu
make clean install
