import os

files = ["f__Acutalibacteraceae_eval_wrapper",  "f__CAG-272_eval_wrapper", "f__Oscillospiraceae_eval_wrapper",
"f__Butyricicoccaceae_eval_wrapper",   "f__CAG-382_eval_wrapper",  "f__Ruminococcaceae_eval_wrapper"]

for file in files:
    os.system("python3 create_kameris_input.py "+file)
    os.system("python3 create_json.py "+file)


