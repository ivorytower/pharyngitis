#!/bin/bash

dir=$(pwd)
if [ $1 ]; then
    dir=$(readlink -m $1)
fi

nw $(dirname "${BASH_SOURCE[0]}")/../pharyngitis.nw $dir &
