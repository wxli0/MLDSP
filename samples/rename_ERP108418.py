import os
import sys

dir = '/mnt/sda/MLDSP-samples-r95/ERP108418/'
for file in os.listdir(dir):
    os.rename(dir+file, dir+file+".gz")