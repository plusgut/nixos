#! /usr/bin/env sh

wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{if($3 == "[MUTED]") {print "-1\n"} else {printf ("%02d\n", $2 * 100)}}'
