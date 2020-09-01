import os
import sys
import platform

folder = sys.argv[1]
total = 0
base_path = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples'
if platform.platform()[:5] == 'Linux':
    base_path = '/home/w328li/MLDSP-desktop/samples'
for dir in os.listdir(base_path+'/'+folder):
    file_num = len(os.listdir(base_path+'/'+folder+'/'+dir))
    print(dir+":", file_num)
    total += file_num
print("total number:", total)
