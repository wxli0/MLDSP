import os
import sys 
import numpy as np

dir = sys.argv[1]
ver = sys.argv[2]
if dir == 'root':
    bac_files = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Bacteria')
    delete_bac = np.random.choice(bac_files, int(len(bac_files)*0.9), replace=False)
    for file in delete_bac:
        os.remove('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Bacteria/'+file)

    arc_files = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Archaea')
    delete_arc = np.random.choice(arc_files, int(len(arc_files)*0.9), replace=False)
    for file in delete_arc:
        os.remove('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Archaea/'+file)
if dir.startswith('d__') or dir == 'p__Actinobacteriota' or dir == 'p__Bacteroidota':
    arc_dirs = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/'+dir)
    for d in arc_dirs:
        all_files = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/'+dir+'/'+d)
        if len(all_files) < 100:
            continue
        delete_files = np.random.choice(all_files, int(len(all_files)*0.9), replace=False)
        for f in delete_files:
            os.remove('/mnt/sda/MLDSP-samples-'+ver+'/'+dir+'/'+d+'/'+f)