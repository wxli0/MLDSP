import os
import sys

folder = sys.argv[1]
base_path = '/home/w328li/MLDSP-desktop/samples'
for dir in os.listdir(base_path+'/'+folder):
    file_num = len(os.listdir(base_path+'/'+folder+'/'+dir))
    print(dir+":", file_num)
