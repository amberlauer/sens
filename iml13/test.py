test.py
import os

path1='/home/al363/Tech/python/incremfolder/'
path2='myfiles.txt'
folder= os.fsencode(path1+path2)

filenames=[]

for file in os.listdir(folder):
        filename=os.fsdecode(file)
        print filename