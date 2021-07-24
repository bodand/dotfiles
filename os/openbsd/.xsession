#!/bin/sh
xrdb -cpp 'cc -E -' -merge "$HOME/.Xresources"
feh --bg-scale "$HOME/dotfiles/openbsd/alena-aenami-lost-1k.jpg" &
picom -bi 0.65 --active-opacity .95 -fc --shadow-exclude "class_g = 'firefox' && argb" --shadow-exclude "class_g = 'Bar'"
perl -I"$HOME/perl5/lib/perl5" -I"$HOME/perl5/lib/perl5/amd64-openbsd" "$HOME/bar.pl" &
exec i3
