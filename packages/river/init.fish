#! /usr/bin/env fish

# This is the example configuration file for river.
#
# If you wish to edit this, you will probably want to copy it to
# $XDG_CONFIG_HOME/river/init or $HOME/.config/river/init first.
#
# See the river(1), riverctl(1), and rivertile(1) man pages for complete
# documentation.

set -l mod Super
set -l notifcation_timeout 6000


riverctl map normal $mod Return spawn $TERMINAL
riverctl map normal $mod E spawn fuzzel
riverctl map normal $mod B spawn firefox
riverctl map normal $mod T spawn "notify-send -t $notifcation_timeout \"\$(date \"+%H:%M - %a %d.%m.\")\""

riverctl map normal $mod Q close

riverctl map normal $mod+Shift E exit

riverctl map normal $mod H focus-view left
riverctl map normal $mod J focus-view down
riverctl map normal $mod K focus-view up
riverctl map normal $mod L focus-view right

# view in the layout stack
riverctl map normal $mod+Shift H swap left
riverctl map normal $mod+Shift J swap down
riverctl map normal $mod+Shift K swap up
riverctl map normal $mod+Shift L swap right

riverctl map normal $mod Period focus-output next
riverctl map normal $mod Comma focus-output previous

riverctl map normal $mod+Shift Period send-to-output next
riverctl map normal $mod+Shift Comma send-to-output previous

set -l workspaces A S D F G
set -l colors 0xfab387 0xf9e2af 0xa6e3a1 0x74c7ec 0xb4befe

for index in $(seq $(count $workspaces))
    set -l tag $(math 2 ^ $(math $index - 1))
    set -l char $workspaces[$(math $index)]
    set -l color $colors[$(math $index)]
    riverctl map normal $mod $char spawn "riverctl background-color $color && riverctl set-focused-tags $tag"
    riverctl map normal $mod+Shift $char set-view-tags $tag
end

# riverctl map normal $mod F toggle-fullscreen

# Declare a passthrough mode. This mode has only a single mapping to return to
# normal mode. This makes it useful for testing a nested wayland compositor
riverctl declare-mode passthrough

riverctl map normal $mod F11 enter-mode passthrough

riverctl map passthrough $mod F11 enter-mode normal

# Various media key mapping examples for both normal and locked mode which do
# not have a modifier
for mode in normal locked
    riverctl map $mode None XF86AudioRaiseVolume spawn 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+'
    riverctl map $mode None XF86AudioLowerVolume spawn 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-'
    riverctl map $mode None XF86AudioMute        spawn 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'
    riverctl map $mode None XF86AudioMicMute     spawn 'wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'

    # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
    riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPlay  spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPrev  spawn 'playerctl previous'
    riverctl map $mode None XF86AudioNext  spawn 'playerctl next'

    # Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
    riverctl map $mode None XF86MonBrightnessUp   spawn 'brightnessctl set +5%'
    riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'
end

# Set background and border color
riverctl background-color $colors[1]
riverctl border-color-focused 0x93a1a1
riverctl border-color-unfocused 0x586e75

# Set keyboard repeat rate
riverctl set-repeat 35 300
riverctl list-inputs \
    | grep '_Touchpad$'  \
    | xargs -I '{}' riverctl input '{}' tap enabled

riverctl rule-add -app-id '*' ssd
# Make all views with an app-id that starts with "float" and title "foo" start floating.
riverctl rule-add -app-id 'float*' float

riverctl focus-follows-cursor normal
riverctl keyboard-layout de
riverctl default-attach-mode below
riverctl xcursor-theme "phinger-cursors-light" 48

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Set the default layout generator to be rivertile and start it.
# River will send the process group of the init executable SIGTERM on exit.
riverctl default-layout rivertile
rivertile -view-padding 8 -outer-padding 8 &
