import os
import pandas as pd

# compute taxon overview
S1_path = '/home/w328li/MLDSP/samples/Table_S1_new.csv'
S1 = pd.read_csv(S1_path, skiprows=0, header=0)
ranks = ['Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
for rank in ranks:
    num = len(set(S1[rank]))
    print(rank+":", num)



