import os
import shutil
import sys
import glob

# argv[1] is the folder to manipulate (transform from MLDSP to Kameris)

input_folder = sys.argv[1]

src = '/home/w328li/MLDSP-desktop/samples/'+input_folder
dest = '/home/w328li/BlindKameris-desktop/data/'+input_folder

if os.path.exists(dest):
    shutil.rmtree(dest, ignore_errors=True)

shutil.copytree(src, dest)

for file in glob.glob(dest+'/*/*'):
    shutil.move(file, dest)

for file in glob.glob(dest+'/'+'?__*'):
    shutil.rmtree(file)
