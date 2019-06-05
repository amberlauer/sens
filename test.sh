#!/bin/bash
rm -R tester
mkdir tester

variable=tester

[ "$(ls -A ./${variable})" ] && echo "not empty" || echo "empty"


touch ./tester/file

[ "$(ls -A ./${variable})" ] && echo "not empty" || echo "empty"
