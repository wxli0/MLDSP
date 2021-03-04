# argv[1]: directory to keep 
# argv[2]: number of files to keep per dir

import numpy as np
import sys
import os
import shutil

# e.g.  python3 count_files.py o__Christensenellales 10
dir = sys.argv[1]
final_num = int(sys.argv[2])

for sub_dir in os.listdir(dir):
    file_names = os.listdir(dir+"/"+sub_dir)
    files_num = len(file_names)
    target_num = files_num-final_num
    if target_num < 0:
        shutil.rmtree(dir+"/"+sub_dir, ignore_errors=True)
        continue
