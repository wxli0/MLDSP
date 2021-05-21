import os
import sys 
import numpy as np

dir = sys.argv[1]
ver = sys.argv[2]
if dir == 'root':
    bac_files = os.listdir('mnt/sda/MLSDP-samples-'+ver+'/root/bacteria')
    delete_bac = np.random.choice(bac_files, int(len(bac_files)*0.9))
    arc_files = os.listdir('mnt/sda/MLSDP-samples-'+ver+'/root/archaea')
    delete_arc = np.random.choice(arc_files, int(len(arc_files)*0.9))
    for file in delete_bac:
        os.remove('mnt/sda/MLSDP-samples-'+ver+'/root/bacteria/'+file)
    for file in delete_arc:
        os.remove('mnt/sda/MLSDP-samples-'+ver+'/root/archaea/'+file)