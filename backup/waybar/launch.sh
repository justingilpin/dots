#!/bin/sh

pkill waybar

if [[ $USER = "justin" ]]
then 
    waybar -c ~/.config/waybar/myconfig & -s ~/.config/waybar/style.css
else
    waybar &
fi
