#!/usr/bin/env python
# coding: utf-8

# In[33]:


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
# change starting model number using variable "start"

#runs_location = input('Enter the location of the runs folders: \n e.g. /Users/ianlapinski/Desktop/REU2020/runs_x100_2/ \n')
data_loc = '/datacommons/phy-champagne-lauer/'
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
    log_lum = []
    row_num = []
    lum = []

    # Fills in the above lists with data

    for j in range(num_models):
        row_num.append(j)
        star_age.append(all_models[j][1])
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

    start_pts = []
    end_pts= []
    min_times = []
    max_times = []
    burst_start = 0
    burst_end = 0
    avg_area = 0
    
    max_log_L = max(peaks_y)
    max_L = 10**(max_log_L)
    max_lums.append(max_L)
    av_y = [0]*19601
    functions = []
    
#The following loop defines the range of values to be analyzed for each burst (start and end)
    
    for j in range(len(peaks_y)-1):
        burst_loc = log_lum.index(peaks_y[j])
        shift = star_age[burst_loc]
        if burst_loc-100 < 0:
            start_pt = 0
        else:
            start_pt = burst_loc-100
        
        if burst_loc+100 > 1500:
            end_pt = 1500
        else:
            end_pt = burst_loc+100
        
        a=0
        
#The follwing finds the start of the burst, using the criteria log(L) < log(L)_peak                   
        for k in range(burst_loc, start_pt, -1):
            if a==0 and log_lum[k]< 0.5*log_lum[burst_loc]:
                   start_pts.append(k)
                   burst_start = k
                   
                   a+=1
        b = 0
        
#Following uses same criteria to find end of the burst

        for k in range(burst_loc,end_pt):
            if b==0 and log_lum[k] < 0.5*log_lum[burst_loc]:
                end_pts.append(k)
                burst_end = k 
                b+=1
                
        burst_t= []
        burst_lum= []
             
#Following creates lists of star age and luminosity, centering the peak of burst at t=0            
            
        for n in range(burst_start, burst_end):
            adjusted_t = (star_age[n]-shift) * 31536000
            burst_t.append(adjusted_t)
            burst_lum.append(lum[n])

#Turns lists into numpy arrays so function can be interpolated linearly, 
# then appends the individual burst function to list            
            
        x= np.array(burst_t)
        y = np.array(burst_lum)    
        f = scipy.interpolate.interp1d(x,y,'linear', fill_value='extrapolate')
        functions.append(f)
    
    
#creates uniform points on time-axis to evaluate luminosity function at (0.1 s intervals between -10 and 150 seconds) 
#This makes it possible to find an average function for entire model
    
    for j in range(len(functions)):
        
        x_new = np.arange(-10,150,.1)
        y_new= functions[j]((x_new))
       
    
   
    y_avg=[]
    
#Following loop sums value of all functions at each data point then divides by number of functions,
# thus returning the average value at point t.
    
    
    for k in range(len(x_new-1)):
        y_sum=0
        for j in range(len(functions)):
            y_sum += functions[j](x_new[k])
            
        y_avg.append(abs(y_sum / (len(functions))))
        
    y_avg = np.array(y_avg)    

#Interpolates this average function, allowing us to find average integrated luminosity
# for each model. Integrates and appends to list.
    
    avg_func = scipy.interpolate.interp1d(x_new,y_avg, 'linear', bounds_error = False, fill_value=0)
    avg_max = avg_func(0)
    avg_max_lums.append(avg_max)
    avg_funcs.append(avg_func)
    
    integral =scipy.integrate.quad(avg_func, -10, 150, epsabs= 300, limit= len(x_new)+1)
    
    integrals.append(integral)
    plt.plot(x_new,y_avg, '-')
    #print(integral)
    

#Follwing loop finds difference between each models average func and the baseline function at each t point, returns absolute value,
# then finds integral over time of burst.

csv_path = data_loc + runs_folder + 'results/'
csv_name = csv_path + 'integrated_lum' + runs_name + '.csv'

if not os.path.exists(csv_path):
    os.makedirs(csv_path)
    

for i in range(len(model_num)):
    
    
    y_baseline = avg_funcs[len(model_num)-1](x_new)
    y_model = avg_funcs[i](x_new)
    
    y_diff = abs(y_model-y_baseline)
    func_int_l = scipy.interpolate.interp1d(x_new,y_diff, 'linear', bounds_error=False, fill_value=0)
    integrated_l = scipy.integrate.quad(func_int_l, -10,150, epsabs=300, limit = len(x_new))
    integrated_ls.append(integrated_l[0])
    #print(integrated_l)
    
#divides by the baseline to determine the relative change (*100 to find %)
    #print(model_num[i])
    relative = str(100*(integrated_l[0]/integrals[len(model_num)-1][0])) + '%'
    perc_diff.append(relative)
    #print(max_lums[i])
    #print(avg_max_lums[i])
    
    
with open(csv_name, 'w', newline='') as data:
        writer=csv.writer(data)
        writer.writerow(['Run Number', 'Integrated L', 'Difference from Baseline', 'Max L', 'Max L (avg func)'])
        for i in range(len(model_num)):
            writer.writerow([model_num[i],integrals[i][0],perc_diff[i],max_lums[i],avg_max_lums[i]] )

#for j in range(len(avg_funcs)):
 #   integral = scipy.integrate.quad(integrand, av_t_start, av_t_end, epsabs = 300, limit = len(x_new)+1)
    
  #  print(integral)


# In[ ]:





# In[ ]:




