#! /usr/bin/env bash

set -e

PREVIOUS_OUTPUT=""

while true
do
   NEW_OUTPUT=$($2)

   if [[ "$PREVIOUS_OUTPUT" != "$NEW_OUTPUT" ]]; then
       PREVIOUS_OUTPUT=$NEW_OUTPUT
       echo $NEW_OUTPUT
   fi
   sleep $1
done
