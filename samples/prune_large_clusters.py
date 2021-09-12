import os
import sys 
import numpy as np

np.random.seed(0)
dir = sys.argv[1]
sample_path = sys.argv[2]
data_type = sys.argv[3]
if data_type == 'GTDB':
    arc_dirs = os.listdir(os.path.join(sample_path, dir))
    for d in arc_dirs:
        all_files = os.listdir(os.path.join(sample_path, dir, d))
        if len(all_files) < 100:
            continue
        delete_files = np.random.choice(all_files, int(len(all_files)*0.9), replace=False)
        for f in delete_files:
            os.remove(os.path.join(sample_path, dir, d, f))
elif data_type == 'HGR':
    arc_dirs = os.listdir(os.path.join(sample_path, dir))
    for d in arc_dirs:
        all_files = os.listdir(os.path.join(sample_path, dir, d))
        if len(all_files) < 100:
            continue
        delete_files = np.random.choice(all_files, int(len(all_files)*0.9), replace=False)
        for f in delete_files:
            os.remove(os.path.join(sample_path, dir, d, f))