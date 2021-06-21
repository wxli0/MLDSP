import os
import sys

dir = '/mnt/sda/MLDSP-samples-r202/dm_species/'
for sub_dir in os.listdir(dir):
    os.system("cat '"+sub_dir+"'/*.fna >  '"+sub_dir+"'_combined.fna")