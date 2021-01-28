import sys
import shutil
import os

dir = sys.argv[1]
clusters = os.listdir(dir)

os.mkdir(dir+'_tmp')
for c in clusters:
    os.mkdir(os.path.join(dir+'_tmp', c+"_wrapper"))
    os.rename(os.path.join(dir, c), os.path.join(dir+'_tmp', c+"_wrapper", c))

os.rmdir(dir)
os.rename(dir+'_tmp', dir)