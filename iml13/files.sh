#!/bin/bash
##files.sh
cwd=$(pwd)
cd ${1}
rm ${cwd}/"${2}"
ls >> ${cwd}/"${2}"
cd ${cwd}