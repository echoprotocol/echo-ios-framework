#!/bin/bash

PATH="../ECHONetworkTests/TestConstantsConfig.xcconfig"

if [ $# -ge 2 ]; then
    KEY=$1
    VALUE=$2

    if [[ $3 != "" ]]; then
        DELETE_FIlE=$3
    else
        DELETE_FIlE="false"
    fi

    echo 'Will add key ' $1 'with value ' $2 'and delete current config' $3
else
    echo "Your command line contains no arguments"
    exit
fi

if [ "$DELETE_FIlE" = "true" ]; then
    echo "$KEY = $VALUE" > "$PATH"
else
    echo "$KEY = $VALUE" >> "$PATH"
fi
