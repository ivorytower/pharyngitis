#!/bin/bash

dir=$(pwd)
if [ $1 ]; then
    dir=$(readlink -m $1)
fi

$(dirname "${BASH_SOURCE[0]}")/../node_modules/.bin/nw $(dirname "${BASH_SOURCE[0]}")/../pharyngitis.nw $dir &
