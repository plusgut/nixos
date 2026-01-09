#! /usr/bin/env sh

magick compare "$2" "$5" sixel:- 2> /dev/null | cat
