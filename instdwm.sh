#!/bin/bash

#sudo apt install git openssh-client ssh
sudo apt install -y lua5.1 build-essential gcc libx11-dev libxft-dev libxinerama-dev dbus-x11
sudo apt install -y vim-gtk sxhkd lxterminal lxtask xfce4-power-manager xfce4-screenshooter

CWD_PATH=`pwd`
git submodule update --init --recursive
cd $CWD_PATH/dwm
make clean install
cd $CWD_PATH/dmenu
make clean install

for filename in $(ls $CWD_PATH/home-scripts)
do
  cp "$CWD_PATH/home-scripts/$filename" "$HOME/.$filename"
done

mkdir -p $HOME/.local/bin
cp "$CWD_PATH/other-scripts/sxhkd" "$HOME/.config/sxhkd/"
