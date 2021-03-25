#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#!/usr/bin/env python
# coding: utf-8

# In[6]:


import numpy as np
from os import listdir
from os.path import isfile, join
import os
import csv
#import mesa_reader as m_r
#import pandas as pd

# Functions:

def tau_lim_finder(all_zones, num_zones, tau_column, zone_stop):
    
    for i in range(num_zones-1):
        
        if all_zones[i][tau_column] < 1 and all_zones[i+1][tau_column]>1:
            #finds which tau value is closest to 1
            
            tau_lim = i #tau_lim is the row at which tau is closest to 1
    return(tau_lim);

def total_mass_finder(all_zones, mass_column, tau_lim):
    
    total_mass = 0
    
    for i in range(tau_lim + 1):
        
        total_mass += all_zones[i][mass_column] 
        #goes through and adds all masses up to tau_lim   
    return(total_mass);

def total_mass_frac_finder(all_zones, mass_column, tau_lim, tau_column, total_mass, nuclides_begin):
    
    total_mass_fracs = [] 
    
    for i in range(nuclides_begin, tau_column): #starts at neutrons and stops before tau column
        
        nuclide_total = 0
        
        for j in range(tau_lim + 1): #this iterates over desired zones
            
            nuclide_total += all_zones[j][i]*all_zones[j][mass_column]
            # goes through and adds up all of the mass fractions for a single nuclide in all desired zones
            # each mass fraction for given nuclide in a zone is weighted by multiplying it by zone mass 
            # before being added to total mass fraction
            
        total_mass_fracs.append(nuclide_total / total_mass) 
        #once all weighted mass fractions have been added, we divide by combined mass of all zones to 
        #get the weighted average mass fraction for each nuclide
        
        
    return(total_mass_fracs); 



def percent_diff_finder(profile_mass_fracs, num_runs, base_profile):
    
    percent_diff = [[0 for x in range(len(total_mass_fracs))] for y in range(num_runs)] 
    #creates a 2d array to fill in percent difference between each nuclide and that of the base profile,
    #for every profile

    for i in range(0, num_runs):
        # num_runs is set as 200, but it only takes odd numbers up to 199, so there is half the number
    
        for k in range(len(total_mass_fracs)):
        
            if profile_mass_fracs[base_profile][k] != 0:
            #this deals with dividing by zero mass fraction values
            
                percent_diff[i][k]= abs((profile_mass_fracs[base_profile][k] - profile_mass_fracs[i][k])/profile_mass_fracs[base_profile][k])
                # Equation: |(x_ibase - x_iprofile)/ x_ibase|
            
            else:
            #right now, if the base profile mass fraction is 0, I set the comparative mass fraction to zero
        
                percent_diff[i][k] = 'undef'
            
    #percent_diff = percent_diff[:-1:]
    #takes off last array element, because it is comparing the base profile to itself
            
    return(percent_diff)

# Adjustable Variables Below

num_zones = 790 #minus 1 because 0th index
mass_column = 9 #1st row in spreadsheet as 0th row as index
tau_column = 314  #for when tau is approximately 1
zone_stop = 1 # tau value that we want to stop counting rows at
nuclides_begin = 12 #column that the actual nuclide information begins
num_profiles = 1 #including 0th! So 6 profiles means variable is 5
base_profile = 0 #the position of the base profile that you're comparing the other files too, in the list below


profile_mass_fracs = []
percent_diff_l = []
full_data_l = []

# change starting model number using variable "start"

#runs_location = input('Enter the location of the runs folders: \n e.g. /Users/ianlapinski/Desktop/REU2020/runs_x100_2/ \n')
data_loc = '/datacommons/phy-champagne-lauer/'
#runs_name = input('Enter name of runs folder\n runs_')
#runs_folder ='runs_'+ runs_name +'/'
#start=int(input('Enter the number associated with the first model folder:'))
#end=int(input('Enter the number associated with the last model folder:'))
#num_files = end+2 # num_files includes baseline!
run_num = []
rxn_list = []

nuclides_names = ['h1','h2','h3','he3','he4','li7','be7','be8','b8','b11','c9','c11','c12','n12','n13','n14','n15','o13','o14','o15','o16','o17','o18','f17','f18','f19','ne18','ne19','ne20','ne21','na20','na21','na22','na23','mg21','mg22','mg23','mg24','mg25','al22','al23','al24','al25','al26','al27','si24','si25','si26','si27','si28','si29','si30','p26','p27','p28','p29','p30','p31','s27','s28','s29','s30','s31','s32','s33','s34','cl30','cl31','cl32','cl33','cl34','cl35','ar31','ar32','ar33','ar34','ar35','ar36','ar37','ar38','k35','k36','k37','k38','k39','ca36','ca37','ca38','ca39','ca40','ca41','ca42','ca43','ca44','sc39','sc40','sc41','sc42','sc43','sc44','sc45','ti40','ti41','ti42','ti43','ti44','ti45','ti46','ti47','v43','v44','v45','v46','v47','v48','v49','cr44','cr45','cr46','cr47','cr48','cr49','cr50','cr51','cr52','mn47','mn48','mn49','mn50','mn51','mn52','mn53','fe48','fe49','fe50','fe51','fe52','fe53','fe54','fe55','fe56','co51','co52','co53','co54','co55','co56','co57','ni52','ni53','ni54','ni55','ni56','ni57','ni58','ni59','ni60','ni61','ni62','cu54','cu55','cu56','cu57','cu58','cu59','cu60','cu61','cu62','cu63','zn55','zn56','zn57','zn58','zn59','zn60','zn61','zn62','zn63','zn64','zn65','zn66','ga59','ga60','ga61','ga62','ga63','ga64','ga65','ga66','ga67','ge60','ge61','ge62','ge63','ge64','ge65','ge66','ge67','ge68','as64','as65','as66','as67','as68','as69','se65','se66','se67','se68','se69','se70','se71','se72','br68','br69','br70','br71','br72','br73','kr69','kr70','kr71','kr72','kr73','kr74','rb73','rb74','rb75','rb76','rb77','sr74','sr75','sr76','sr77','sr78','y77','y78','y79','y80','y81','y82','zr78','zr79','zr80','zr81','zr82','zr83','nb81','nb82','nb83','nb84','nb85','mo82','mo83','mo84','mo85','mo86','tc85','tc86','tc87']


for j in range(1):
   
    s = 'baseline_abund'
    run_num.append(s)
    path = data_loc + s + '/'
            #insert the path to the folder containing the stellar profiles/ leave "r'" if you have a mac.
    file = 0
    for i in os.listdir(path):
        if i.startswith('abund_profile') and i.endswith('.data'):
            if i != 'final.mod':
                file = i
                rxn_list.append(i)
    
    if file == 0:
        for i in os.listdir(path):
            if i.startswith('final_profile') and i.endswith('.data'):
                if i != 'final.mod':
                    rxn_list.append('i')
                    profile_mass_fracs.append([0]*304)
    else:
        new_path = path + file
    
    #creates path for which specific profile we wish to open
    
        with open(new_path,'r') as f:
    #Note: leave "r'" in front of file path, even when changing the path

                zones_begin = 0   #counter so that only lines with zone information get turned into float arrays

                all_zones = []    #list that zone_elements array is fed into, so every index is info. for an entire zone

                nuclide_label = []

                for line in f:

                    zones_begin += 1

                    zone_info = line.split(" ")    #splits the individual numbers in the lines

                    zone_info = np.array(list(filter(None, zone_info)))[:-1:] 
                    #gets rid of spaces and '\n' and puts each list element into the array

                    
                    if zones_begin == 5:
                        tau_column = line.split(" ")
                        tau_column = np.array(list(filter(None, tau_column)))[-2]
              
                        tau_column = tau_column.astype(int) -2
                    if zones_begin == 6:

                # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
                # code related to this if statement creates nuclide dictionary                                    #
                # connecting each nuclear species to it's respective element position within the total_mass_frac  #
                # array. To search for specific element, insert "nuclides['name of nuclide']" into the second     #
                # index of total_mass_fracs[i][j] (i.e. the j index)                                              #
                # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

                        nuclides = {}

                        for i in range(tau_column - nuclides_begin):

                            nuclides[zone_info[i + nuclides_begin]] = i

                    if zones_begin >= 7 : 
                    #distinguishes zone information from other info and labels, like the names of the nuclides 

                        zone_elements = zone_info.astype(float)

                        all_zones.append(zone_elements) #puts each zone_element iteration into all_zones list

                num_zones = len(all_zones)
                #sets the number of zones to that of the number of zone rows in this particular file iteration

                all_zones = np.array(all_zones)
                #format: all_zones[i][j]
                #first bracket is the zone you want -minus one because zeroth index-
                #second bracket is what component you want from a single zone, i.e. mass fraction / mass of zone / zone number

        #functions defined at bottom of script
        tau_lim = tau_lim_finder(all_zones, num_zones, tau_column, zone_stop)

        total_mass = total_mass_finder(all_zones, mass_column, tau_lim)

        total_mass_fracs = total_mass_frac_finder(all_zones, mass_column, tau_lim, tau_column, total_mass, nuclides_begin)
    #print(total_mass_fracs)
        profile_mass_fracs.append(total_mass_fracs)
    
    #puts each profile mass fractions into an array of them

first_row_rxns = []
for i in range(len(list(nuclides))):
    first_row_rxns.append(list(nuclides)[i])
    first_row_rxns.append('difference')
    
first_row = ['Run Number','Rxn'] + first_row_rxns   
csv_path = data_loc +'results/baseline_mass_frac.csv'

num_runs = len(profile_mass_fracs)
base_profile = num_runs - 1
percent_diff_l = percent_diff_finder(profile_mass_fracs, num_runs, base_profile)




with open(csv_path, 'w', newline = '') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(first_row)
    for i in range(len(profile_mass_fracs)):
        print
        for v in range(len(profile_mass_fracs[i])):
            full_data_l.append(profile_mass_fracs[i][v])
            full_data_l.append(percent_diff_l[i][v])
        second_row = [run_num[i],rxn_list[i][16:31]] + full_data_l
        writer.writerow(second_row)
        full_data_l=[]



#for i in range((num_runs//2)):
   # print(percent_diff[i],'\n')
        #prints the percent difference for every nuclide in each profile compared to the base profile for all profiles


# In[ ]:




