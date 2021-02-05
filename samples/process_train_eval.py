import os
import sys

dir = sys.argv[1]

os.system("python3 sep_eval.py "+dir)
os.system("python3 make_nested_wrapper.py "+dir+"_eval")
os.system("python3 create_kameris_input.py "+dir)
os.system("python3 create_kameris_input.py "+dir+"_train")
os.system("python3 create_json.py "+dir)
os.system("python3 create_json.py "+dir+"_train")
os.system("python3 run_kameris_json.py "+dir+"_eval")


