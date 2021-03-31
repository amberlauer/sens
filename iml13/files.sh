#!/bin/bash
##files.sh
cwd=$(pwd)
cd ${1}
ls >> ${cwd}/files"${2}".txt
cd ${cwd}