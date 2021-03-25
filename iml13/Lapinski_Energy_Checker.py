#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import numpy as np
import matplotlib.pyplot as plt
import csv
import scipy
import os.path
from os.path import isfile, join
#import pandas as pd
from scipy.signal import find_peaks
from scipy.interpolate import interp1d 
from scipy.integrate import quad


peak_frequency = []
num_peaks = []
run_num = []
time_step = []
multiple_500=[]
start_pts = []
end_pts= []
integrals = []
integrated_ls = []
perc_diff = []
avg_funcs = []
min_times_all =[]
max_times_all = []
model_num = []
max_lums=[]
avg_max_lums=[]
tester = []
tester_log = []
# change starting model number using variable "start"

#runs_location = input('Enter the location of the runs folders: \n e.g. /Users/ianlapinski/Desktop/REU2020/runs_x100_2/ \n')
data_loc = '/datacommons/phy-champagne-lauer/1b_runs/'
runs_name = input('Enter name of runs folder\n runs_')
runs_folder ='runs_'+ runs_name +'/'
start=int(input('Enter the number associated with the first model folder:'))
end=int(input('Enter the number associated with the last model folder:'))
num_files = end+2 # num_files includes baseline!

for i in range(start, num_files+2, 2): # goes through odd files
    s = str(i) # changes int i into string s

    path1 = data_loc+runs_folder
    path2 = '/LOGS/history.data'
    file_path = path1 + s + path2
    
    if i == num_files:
        s = 'baseline'
        file_path = data_loc + s + path2

    print(s)
    model_num.append(s)
    
    with open( file_path, 'r') as f:

        info_starts = 0
        data = []
        all_models = []

        for line in f:

            info_starts += 1

            model_info = line.split(" ")    # splits the individual numbers in the lines

            model_info = np.array(list(filter(None, model_info)))[:-1:]
            
            if info_starts == 5: # identifies tau column
                last_column = line.split(" ")
                last_column = np.array(list(filter(None, last_column)))[-2]
                last_column = last_column.astype(int) -1
                
                
            if info_starts == 6:
            
                column_name = {}
                
                for k in range(last_column):
                    column_name[model_info[k]] = k
                    

            if info_starts >= 7:     # This is where we care about the data

                model_elements = model_info.astype(float)

                all_models.append(model_elements)

                num_models = len(all_models)

    # This creates lists for star age and log luminosity

    star_age = []
    row_num = []
    lum = []
    log_lum = []
    
    

    # Fills in the above lists with data

    energy_cols = ['log_tot_E', 'tot_E']
    
    if 'log_tot_E' in column_name:
        tester_log.append(1)
    else: 
        tester_log.append(0)
        
    if 'tot_E' in column_name:
        tester.append(1)
    else:
        tester.append(0)
            
            
csv_path = data_loc + runs_folder + 'results/'
csv_name = csv_path + 'E_column_check_' + runs_name + '.csv'

if not os.path.exists(csv_path):
    os.makedirs(csv_path)
    
    
    
with open(csv_name, 'w', newline='') as data:
        writer=csv.writer(data)
        writer.writerow(['Run Number', 'log_total_E', 'total_E'])
        for i in range(len(model_num)):
            writer.writerow([model_num[i],tester_log[i], tester[i]] )

