#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import numpy as np
import matplotlib.pyplot as plt
import csv
import os
from os.path import isfile, join
data_loc = '/datacommons/phy-champagne-lauer/'
runs_folders = []
int_lum=[]

def p2f(x):
    if x.startswith('D'):
        return(1)
    else:
        return(float(x.strip('%'))/100)

def find_data(x):
    return(x[2])

with os.scandir(data_loc) as data:
    for folder in data:
        if folder.name.startswith('runs'):
            with os.scandir(folder) as model_folder:
                for folder in model_folder:
                    if folder.name.startswith('results'):
                        with os.scandir(folder) as results:
                            for file in results:
                                if file.name.startswith('int'):
                                    path = os.path.abspath(file.path)
                                    print(path)
                                    with open(path) as int_lum_data:
                                        reader = csv.reader(int_lum_data)
                                        next(reader)
                                        for row in reader:
                                            row[2]=p2f(row[2])
                                            int_lum.append(row)
                                                
                                            
            
            runs_folders.append(folder)
            #for i in range(len(runs_folders)):
                #with os.scandir(runs_folders[i]) as runs_data:
                          # for folder in runs_data:
                            #   if folder.name.isnumeric():
                                   #print(folder)
                            
int_lum.sort(reverse=True, key=find_data)
print(i[0] for i in int_lum)

