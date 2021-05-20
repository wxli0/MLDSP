import sys 
import os 
import pandas as pd

r95 = pd.read_csv("sp_clusters_r95.tsv", sep='\t', header = 0, index_col = 0)
r202 = pd.read_csv("sp_clusters_r202.tsv", sep='\t', header = 0, index_col = 0)
print("==== checking representative genome changes between r95 and r202 ====")

for index, row in r95.iterrows():
    if index not in r202.index:
        print(index, "ADDED")
        continue
    r202_row = r202.loc[index]
    if r202_row['GTDB_species'] != row['GTDB_species']:
        print(index+":", "FROM")
        print("r95 :", row['GTDB_taxonomy']+";"+row['GTDB_species'], "TO")
        print("r202:", r202_row['GTDB_taxonomy']+";"+r202_row['GTDB_species'])