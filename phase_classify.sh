#!/bin/bash

cd ~/MLDSP
if [ "$1" == "GTDB" ]; then
    matlab -r "run addme;stackedMain('$1', '$2', 'rumen_mags/$2');exit"
elif [ "$1" == "HGR" ]; then
    matlab -r "run addme;stackedMain('$1', '$2_split_pruned', 'hgr_mags/$2');exit"
fi