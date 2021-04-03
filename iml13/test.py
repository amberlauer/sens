#!/usr/bin/env python

import os

path1='/home/al363/Documents/Tech/MESA/XRB/'
path2='sens/iml13/'
path=path1+path2
name='test'
bashCommand="bash files.sh "+ path+" "+ name
os.system(bashCommand)
filename='files'+name+'.txt'
with open(filename) as f:
       lines = [line.rstrip() for line in f]
       print(lines[])
#filenames=[]

#open()
#        filename=os.fsdecode(file)
#        print(filename)

