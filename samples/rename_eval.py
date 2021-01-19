import os
import sys
from shutil import copyfile

# e.g. python3 

dir = sys.argv[1]
files = os.listdir(dir)

for file in files:
    os.rename(os.path.join(dir, file), os.path.join(dir, file+'_eval'))
    os.mkdir(file+'_eval_wrapper')
    copyfile(os.path.join(dir, file+'_eval'), os.path.join(file+'_eval_wrapper', file+'_eval'))
