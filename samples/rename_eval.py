import os
import sys
from shutil import copyfile
from distutils.dir_util import copy_tree

# e.g. python3 

dir = sys.argv[1]
files = os.listdir(dir)

for file in files:
    os.rename(os.path.join(dir, file), os.path.join(dir, file+'_eval'))
    if not os.path.exists(file+'_eval_wrapper'):
        os.mkdir(file+'_eval_wrapper')
    copy_tree(os.path.join(dir, file+'_eval'), os.path.join(file+'_eval_wrapper', file+'_eval'))
