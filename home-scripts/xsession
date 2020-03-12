#!/bin/bash

export PATH=$HOME/.local/bin:$HOME/bin:$PATH

sh $HOME/.profile
xrdb $HOME/.Xresources
setxkbmap ro

sh $HOME/.screenlayout/default.sh &
sh $HOME/.fehbg &

xautolock -exit
xautolock -time 5 -locker lock -notify 5 &

dwmstatus.lua &
xfce4-power-manager &
pnmixer &
sxhkd &

exec dbus-launch --exit-with-session dwm >> $HOME/.dwm.out 2>> $HOME/.dwm.err
