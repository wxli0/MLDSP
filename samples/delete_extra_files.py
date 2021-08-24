"""
Deletes extra files in a target directory (sys.argv[1]) with files that \
    are above a target number (sys.argv[2])

:param sys.argv[1]: dir. Target directory of files.
:type sys.argv[1]: str
:param sys.argv[2]:  final_num. Target number to determine extra files.
:type sys.argv[2]: str

:Example: python3 delete_extra_files.py samples/g__Prevotella
"""

import numpy as np
import os
import sys

np.random.seed(0)
dir = sys.argv[1]
final_num = int(sys.argv[2])

for sub_dir in os.listdir(dir):
    file_names = os.listdir(dir+"/"+sub_dir)
    files_num = len(file_names)
    target_num = files_num-final_num
    # if less than final_num, do not prune
    if target_num < 0:
        continue
    selected_files = np.random.choice(file_names, target_num, replace=False)
    for file in selected_files:
        os.remove(dir+"/"+sub_dir+"/"+file)