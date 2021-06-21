import os
import sys
import pandas as pd

dir = '/mnt/sda/MLDSP-samples-r202/dm_species/'
MLDSP_pred_path = '/home/w328li/BlindKameris-new/outputs-r202/MLDSP-prediction-full-path.csv'

MLDSP_df =  pd.read_csv(MLDSP_pred_path, index_col=0, header=0, dtype = str)
MLDSP_species = MLDSP_df['gtdb-tk-species']

for file in os.listdir(dir):
    index = file.split('_combined.fna')[0]
    if index not in MLDSP_species:
        print(index, "not in MLDSP_species")

for s in MLDSP_species:
    index = s+'_combined.fna'
    if index not in os.listdir(dir):
        print(index, "not in dir")