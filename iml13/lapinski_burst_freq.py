#!/usr/bin/env python
# coding: utf-8

# In[11]:


import numpy as np
import matplotlib.pyplot as plt
import csv
import os.path
from os.path import isfile, join
import pandas as pd
from scipy.signal import find_peaks


peak_frequency = []
num_peaks = []
run_num = []
time_step = []
multiple_500=[]
# change starting model number using variable "start"

runs_location = input('Enter the location of the runs folder: \n e.g. /Users/ianlapinski/Desktop/REU2020/runs_x100_2/ \n')

start=int(input('Enter the number associated with the first model folder:'))
end=int(input('Enter the number associated with the last model folder:'))
num_files = end+2 # num_files includes baseline!

for i in range(start, num_files, 2): # goes through odd files
    if i == num_files:
        s = 'baseline'
    else:
        s = str(i) # changes int i into string s

    path1 = runs_location
    path2 = '/LOGS/history.data'
    file_path = path1 + s + path2

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

    # Fills in the above lists with data

    for j in range(num_models):
        row_num.append(j)
        star_age.append(all_models[j][1])
        log_lum.append(all_models[j][column_name['log_L']])


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

                


    if len(peaks_y) > 4:
        for t in range(row_check[4+removed], row_check[4+removed]+100):
            if q==0 and log_lum[t] < 0.5*log_lum[row_check[4+removed]]:
                time_step.append(t)
                for x in range(6):
                    up = 500 * (x+1)
                    down = 500 * x
                    if t < up and t > down:
                        multiple_500.append(down)
                    
        
                #print('For Model number ' + str(i) + '\n row=' + str(t) + '\n burst =' +str(row_check[4+removed]))
                q+=1
    else:
        time_step.append('DNC')
        multiple_500.append('DNC')
        #print(i)
        
        
    # Finds Burst Frequency (if there's more than one peak)
    num_peaks.append(len(peaks_x))
    peak_dist_sum = 0

    if len(peaks_x) == 1:
        print('\n\n\n','Only one peak', '\n\n\n')
        run_num.append(s)
    else:
        for k in range(len(peaks_x)-1):

            peak_dist_sum += (peaks_x[k+1]- peaks_x[k])
            #gets sum distance between all peaks

        burst_frequency = peak_dist_sum / (len(peaks_x) - 1)
       # divides by number of peaks (minus one b/c its an avg. 
        # over distance B E T W E E N peaks)

        peak_frequency.append(burst_frequency)
        run_num.append(s)
        print(burst_frequency, '     run number: ',s, '\n\n')
        print(peaks_x, '\n\n',peaks_y, '\n\n')

peak_frequency = np.array(list(peak_frequency))

#total_rows = (end-start)/2 + 2
csv_path = runs_location + 'results/'
csv_name = csv_path + 'test_values.csv'
if os.path.exists(csv_path + 'test_values.csv'):
    x = input('Would you like to overwrite test_values.csv? [y/n] \n')
    if x == 'y' or x == 'Y':
        csv_name = csv_path + 'test_values.csv'
    else:
        csv_name = csv_path + input('Enter a name for the csv file, \n including .csv at end of name\n')
with open(csv_name, 'w', newline='') as data:
        writer=csv.writer(data)
        writer.writerow(['Run Number','Baseline After Peak 5', 'Closest Reset Point'])
        for z in range(len(time_step)):
            writer.writerow([run_num[z], time_step[z], multiple_500[z]])    


# In[8]:


y = np.linspace(1, 1)
df = pd.DataFrame(data = num_peaks, index = run_num)
# creates a data frame using pandas - essentially tells code below where the data is stored 
spread_path = runs_location + 'results/num_peaks_.01_10.xlsx'
writer = pd.ExcelWriter(spread_path, engine='xlsxwriter')
df.to_excel(writer, index=True)
writer.save()

# The above creates, writes in the data, then saves and excel spreadsheet


# In[22]:





# In[23]:





# In[ ]:




