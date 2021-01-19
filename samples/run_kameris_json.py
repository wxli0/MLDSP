import os
import sys

dir = sys.argv[1]
files = os.listdir(dir)

for file in files:
    file = file+"_eval_wrapper"
    os.system("python3 create_kameris_input.py "+file)
    os.system("python3 create_json.py "+file)


