#!/bin/bash
cat $1 | while read L; do  echo $L; read L; echo "$L" | rev | tr "ATGC" "TACG" ; done
 
