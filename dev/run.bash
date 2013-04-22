#!/bin/bash

dir=$(pwd)
if [ $1 ]; then
    dir=$(readlink -m $1)
fi

nw pharyngitis.nw $dir
