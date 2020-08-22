# argv[1]: directory to keep 
# argv[2]: number of files to keep per dir

import numpy as np
import sys
import os

dir = sys.argv[1]
final_num = int(sys.argv[2])

for sub_dir in os.listdir(dir):
    file_names = os.listdir(dir+"/"+sub_dir)
    files_num = len(file_names)
    target_num = final_num-files_num
    print(final_num)
    print(files_num)
    if target_num <= 0:
        continue
    selected_files = np.random.choice(file_names, final_num-files_num)
    for file in selected_files:
        os.remove(dir+"/"+sub_dir+"/"+file)