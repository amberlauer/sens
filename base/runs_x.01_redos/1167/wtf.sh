#!/bin/bash
if stat --printf='' ./final_profile** 2>/dev/null
then
 	echo "found"
else
	echo "not found"
fi
