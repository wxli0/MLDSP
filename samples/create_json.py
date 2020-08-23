import os
import sys
import json

input_dir = sys.argv[1]
input_base_path = '/home/w328li/MLDSP-desktop/samples/'
input_dir_path = input_base_path+input_dir+"/"
output_dir_path = '/home/w328li/BlindKameris/data/'
clusters = os.listdir(input_dir_path)
dict_arr = []
for c in clusters:
    input_path = input_base_path+input_dir+"/"+c
    for file in os.listdir(input_path):
        dict_arr.append({
            "subtype": c,
            "id": file[:-6]
        })

with open(output_dir_path+input_dir+".json", "w") as outfile:  
    json.dump(dict_arr, outfile)

