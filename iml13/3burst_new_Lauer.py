#!/usr/bin/env python
# coding: utf-8

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import csv
import os.path
from os.path import isfile, join
from scipy.signal import find_peaks
from scipy.interpolate import interp1d
import subprocess
import os
import fileinput
import glob
import sys
peak_period = []
num_peaks = []
run_num = []
benchmarks = []
multiple_500=[]
# file locations: results=results_loc , main data folder=data_loc, ind data folder=runs_name, history and final path self explan
# these values don't change so I put them together.
#results_loc ='/datacommons/phy-champagne-lauer/1_runs/results/'
results_loc='/home/al363/Documents/Tech/MESA/XRB/XRB_SENS_analysis/runs/results/'
#data_loc = '/datacommons/phy-champagne-lauer/1_runs/'
data_loc='/home/al363/Documents/Tech/MESA/XRB/XRB_SENS_analysis/runs/'
#runs_name = input('Enter **Full** name of runs folder \n')
runs_name='runs_x.01_8'
runs_folder=data_loc+runs_name+'/'
baseline_path=data_loc+'/baseline/LOGS/history.data'
history_path = '/LOGS/history.data'
final_path= "/final_*"## note that this includes wildcard!!! That's why used special func "glob" below. it handles *.


# check if folders exist, if not exit compilation
if not (os.path.exists(results_loc)):    
    print(results_loc+ " results_loc doesn't exist")
    sys.exit()

if not (os.path.exists(data_loc)):    
    print(data_loc +" data_loc folder doesn't exist")
    sys.exit()

if not (os.path.exists(runs_folder)):    
    print(runs_folder +" runs_folder doesn't exist")
    sys.exit()

if not (os.path.exists(baseline_path)):    
    print(baseline_path +" baseline_path folder doesn't exist")
    sys.exit()


#####changed so script prints a list of files in folder and then reads from
file_name=runs_name+"_list.txt"
bashCommand="bash files.sh "+ runs_folder+" "+ file_name ## os.system takes unlimted vars as a string, first should be executable, then any vars passed.
os.system(bashCommand)
with open(file_name) as f:
    lines = [line.rstrip() for line in f]
baseline_path=data_loc+'/baseline/LOGS/history.data'

#for i in ra8h1 = data_loc
#for line in range(0, cap, 1): # goes through odd files        
#    else:
#s = 'baseline'
#s=lines[i]
######

## have to set initial values
cap=int(len(lines))
i=0
path1=lines[i]
final_prof_path=runs_folder+path1+final_path        
file_path=runs_folder+path1+history_path

#### debug print statements
print(final_prof_path)
print(data_loc)
print(runs_name)
print(runs_folder)
print(lines[i])
print(path1)   
print(glob.glob(final_prof_path))
print(cap)
input("press any key to continue")

###### new loop iterate through the list of files  
for i in range(0, cap+1,1):    
    print(cap+1)
    print(i)
    if i == cap:
        file_path=baseline_path  

    else:
        path1=lines[i]
        final_prof_path=runs_folder+path1+final_path
        file_path=runs_folder+path1+history_path      
        print(file_path)
        print(final_prof_path)
        
        #### check if final*profile exists. Want only finished runs   
        if not (glob.glob(final_prof_path)): 
            print("final profile doesn't exist")  
            print(i)
            print(final_prof_path)
            continue  

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
                num_models = len(all_models)   # This creates lists for star age and log luminosity

        star_age = []
        log_lum = []
        row_num = []
        lum = []
        model_num=[]

        # Fills in the above lists with data

        for j in range(num_models):
            row_num.append(j)
            star_age.append(all_models[j][1])
            model_num.append(all_models[j][column_name['model_number']])
            log_lum.append(all_models[j][column_name['log_L']])
            lum.append(all_models[j][column_name['luminosity']])


        peaks_x = []
        peaks_y = []
        row_check = []
        x = []
        y = []
        av_lum = []
        total = 0
        removed = 0
        q=0


        # Filling lists with differences of luminosity points 

        for j in range(len(log_lum) - 1):     
                x.append(log_lum[j]-log_lum[j-1]) 
                y.append(log_lum[j+1]-log_lum[j]) 
                if log_lum[j] > 0 and log_lum[j+1] - log_lum[j] < .01:
                    av_lum.append(log_lum[j])

        # Finds peaks by saying that if luminosities are increasing and then switch to decreasing at a luminosity point
        # then that point is a peak if it's above a certain threshold  
    
        for k in range(len(x)):
            if x[k] > 0 and y[k] < 0 and log_lum[k] > 4.5:
                row_check.append(row_num[k])
                peaks_x.append(star_age[k]*31536000) #converts years to seconds
                peaks_y.append(log_lum[k])

       # Checks for extra peaks included by seeing if the peak's row numbers are too close
        # (there's a peak approx. every 35 rows - I use 20 to be cautious)
        # if a peak is less than 20 rows away from the previous, I take the highest one as
        # the peak and discard the other since it is a data anomaly 
        #Also keeps track of removed bursts before the fifth burst


        row_check = np.array(list(row_check))
        offset = 0
        for m in range(len(row_check)-1):
            if (row_check[m+1] - row_check[m]) < 20:
                if m - offset < 4: 
                    removed +=1 
                if peaks_y[m - offset] < peaks_y[(m-offset)+1]: 
                    peaks_y.remove(peaks_y[(m-offset)])        
                    peaks_x.remove(peaks_x[(m-offset)])
                    offset += 1                                   
                else: 
                    peaks_y.remove(peaks_y[(m-offset)+1]) 
                    peaks_x.remove(peaks_x[(m-offset)+1])
                    offset += 1




        if len(peaks_y) > 2:
            for t in range(row_check[2+removed], len(row_num)-1):
                if q==0 and log_lum[t] < 0.53*log_lum[row_check[2+removed]]:
                    temp = model_num[t]
                    print(temp)
                    benchmarks.append(temp)
                    for x in range(6):
                        up = 500 * (x+1)
                        down = 500 * x
                        if temp < up and temp >= down:
                            multiple_500.append(down)


                    #print('For Model number ' + str(i) + '\n row=' + str(t) + '\n burst =' +str(row_check[4+removed]))
                    q+=1
        else:
            benchmarks.append('DNC')
            multiple_500.append('DNC')
            #print(i)


        # Finds Burst Frequency (if there's more than one peak)
        num_peaks.append(len(peaks_x))
        peak_dist_sum = 0

        if len(peaks_x) == 1:
            print('\n\n\n','Only one peak', '\n\n\n')
            run_num.append(path1)
            peak_period.append('DNC')
        else:
            for k in range(len(peaks_x)-1):
                peak_dist_sum += (peaks_x[k+1]- peaks_x[k])
                #gets sum distance between all peaks

            burst_period = peak_dist_sum / (len(peaks_x) - 1)
           # divides by number of peaks (minus one b/c its an avg. 
            # over distance B E T W E E N peaks)

            peak_period.append(burst_period)
            run_num.append(path1)
            #print(burst_frequency, '     run number: ',s, '\n\n')
            #print(peaks_x, '\n\n',peaks_y, '\n\n')



#total_rows = (end-start)/2 + 2
csv_name = results_loc + '3_peak_info_' + runs_name+ '.csv'

if not os.path.exists(results_loc):
    os.makedirs(results_loc)

rel_period = []
delta_period = []
    
#if os.path.exists(results_loc + 'test_values.csv'):
 #   x = input('Would you like to overwrite test_values.csv? [y/n] \n')
  #  if x == 'y' or x == 'Y':
   #     csv_name = results_loc + 'peaks_info_' + runs_name + '.csv'
    #else:
     #   csv_name = results_loc + input('Enter a name for the csv file, \n including .csv at end of name\n')
        
        

        
with open(csv_name, 'w', newline='') as data:
        writer=csv.writer(data)
        writer.writerow(['Run Number', 'Number of Peaks', 'Benchmark', 'Closest Reset Point', 'Burst Period','Period Ratio', 'Period Difference'])
        for z in range(len(benchmarks)):
            print(peak_period[z])
            if peak_period[z] == 'DNC':
                
                rel_period.append('DNC')
                delta_period.append('DNC')
            else:
                #finds ratio of period to baseline
               
                
                rel_period.append(abs(peak_period[z]/peak_period[-1]))
            
                #finds difference as fraction of baseline
            
                delta_period.append(abs((peak_period[z]-peak_period[-1])/peak_period[-1]))
            
            writer.writerow([run_num[z], num_peaks[z], benchmarks[z], multiple_500[z], peak_period[z],rel_period[z],delta_period[z]])    
num_peaks_loc = results_loc + 'num_peaks.csv'


#y = np.linspace(1, 1)
#df = pd.DataFrame(data = num_peaks, index = run_num)
# creates a data frame using pandas - essentially tells code below where the data is stored 
#spread_path = runs_location + 'results/num_peaks_.01_10.xlsx'
#writer = pd.ExcelWriter(spread_path, engine='xlsxwriter')
#df.to_excel(writer, index=True)
#writer.save()

# The above creates, writes in the data, then saves and excel spreadsheet

