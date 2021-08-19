"""
Downloads original test genome file for Task 1 (simulated/sparse). The downloaded \
    files are not currently used. However, it might be useful for future tunning \
        the hyperparameters.

No command line arguments are required.
"""

import os 
import pandas as pd 


df = pd.read_csv("ERP108418_meta.csv", delimiter='\t')
print(df)
print(df[['submitted_ftp']])
true_path = "Table_S2.csv"
S2 = pd.read_csv(true_path, skiprows=0, header=1)
print(S2["MAG_ID_ENA"])

# constuct dictionary
dict = {}
for ftp in df['submitted_ftp']:
    dict[ftp.split('/')[-1][:-6]] = ftp

download_urls = []
for mag in S2["MAG_ID_ENA"]:
    download_urls.append(dict[mag])
print(download_urls)

# curl urls
os.mkdir("/mnt/sda/MLDSP-samples/ERP108418")
for url in download_urls:
    os.system("(cd /mnt/sda/MLDSP-samples/ERP108418 && curl -O -L "+url+")")
    print("(cd /mnt/sda/MLDSP-samples/ERP108418 && curl -O -L "+url+")"+" done")

