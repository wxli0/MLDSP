#!/bin/bash

cd ~/MLDSP
matlab -r "run addme;stackedMain('$1', '$2', 'rumen_mags/$2');exit"