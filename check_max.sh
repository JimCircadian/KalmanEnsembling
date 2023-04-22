#!/usr/bin/env bash

if [ -f REPEAT ] && [ $( wc -m <REPEAT ) -ge $1 ]; then
    exit 1
fi

exit 0
