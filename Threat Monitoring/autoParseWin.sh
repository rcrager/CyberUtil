#!/bin/bash

#########################
#  Script to auto pull  #
#  logging data for     #
#  parseWindows script  #
#  & run it.            #
#########################

if [ $# -eq 0 ] || [ $1 = "-h" ];
then
 echo "Script to pull windows logs, parse them, and auto export to user tmp directory"
 echo "First parameter is date in YYYY/MM/DD format"
 echo "Second param is search term for windows logs (endpoint name)."
 exit 1
fi

echo "Running SDL command with parameters ($1 & $2)"
file=$(PATH_REDACTED | grep "Copying output" | cut -d " " -f 4)

$(cat $file | python3 PATH_REDACTED/parseWindows.py -sA > PATH_REDACTED/output.txt)
