"""
Deletes subcluster in a directory (sys.argv[1]) with files less than a number \
    (sys.argv[2])

Command line arguments:
:param sys.argv[1]: dir. The directory to check subdirectories.
:type sys.argv[1]: str
:param sys.argv[2]: final_num. Fewest number of files in subdirectories. Delete \
    the subdirectory if it does not have

:Example python3 delete_small_cluster.py samples/g__Prevotella
"""

import os
import shutil
import sys


dir = sys.argv[1]
final_num = int(sys.argv[2])

# delete folder with file num < final_num
for sub_dir in os.listdir(dir):
    file_names = os.listdir(dir+"/"+sub_dir)
    files_num = len(file_names)
    target_num = files_num-final_num
    if target_num < 0:
        shutil.rmtree(dir+"/"+sub_dir, ignore_errors=True)
        continue
