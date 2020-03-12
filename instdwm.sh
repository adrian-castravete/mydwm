#!/bin/bash

#sudo apt install git openssh-client ssh
sudo apt install -y lua5.3 lua5.1 build-essential gcc libx11-dev libxft-dev libxinerama-dev dbus-x11
sudo apt install -y vim-gtk sxhkd lxterminal suckless-tools xautolock lxtask xfce4-power-manager \
        xfce4-screenshooter pcmanfm feh sxiv arandr pnmixer

CWD_PATH="$(pwd)"
git submodule update --init --recursive
cd $CWD_PATH/dwm
make clean install
cd $CWD_PATH/dmenu
make clean install

for filename in $(ls $CWD_PATH/home-scripts)
do
  cp "$CWD_PATH/home-scripts/$filename" "$HOME/.$filename"
done

mkdir -p "$HOME/.local/bin"
for filename in $(ls $CWD_PATH/bin-scripts)
do
  cp "$CWD_PATH/bin-scripts/$filename" "$HOME/.local/bin"
done

mkdir -p $HOME/.config/sxhkd
cp "$CWD_PATH/other-scripts/sxhkdrc" "$HOME/.config/sxhkd/"
