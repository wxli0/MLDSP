import os 
import sys 
import pandas as pd 

df = pd.read_csv("ERP108418_meta.csv", delimiter='\t')
print(df)
print(df[['submitted_ftp']])
true_path = "Table_S2.csv"
S2 = pd.read_csv(true_path, skiprows=0, header=1)
print(S2["MAG_ID_ENA"])
print(len(S2["MAG_ID_ENA"]))

all_files = os.listdir("/mnt/sda/MLDSP-samples/ERP108418")
missing = []
for mag in S2["MAG_ID_ENA"]:
    if mag+".fa.gz" not in all_files:
        print(mag+".fa.gz" + "missing")
        missing.append(file)
print("length of missing files are:", len(missing))
