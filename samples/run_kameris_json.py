import os
import sys

dir = sys.argv[1]
files = os.listdir(dir)

for file in files:
    os.system("python3 create_kameris_input.py "+os.path.join(dir, file))
    os.system("python3 create_json.py "+os.path.join(dir,file))


