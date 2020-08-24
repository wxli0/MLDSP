import os
import sys
import platform

folder = sys.argv[1]
base_path = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples'
if platform.platform() == 'Linux-5.3.0-61-generic-x86_64-with-debian-buster-sid':
    base_path = '/home/w328li/MLDSP-desktop/samples'
for dir in os.listdir(base_path+'/'+folder):
    file_num = len(os.listdir(base_path+'/'+folder+'/'+dir))
    print(dir+":", file_num)
