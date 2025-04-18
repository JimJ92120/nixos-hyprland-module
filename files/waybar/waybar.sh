#! /usr/bin/env nix-shell
#! nix-shell -i bash -p bash

killall waybar

if [[ $USER = "jim" ]]
then
  waybar -c ~/.config/waybar/config.jsonrc & -s ~/.config/waybar/style.css
else
  waybar &
fi
