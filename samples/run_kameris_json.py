import os

files = ["o__Bacteroidales_eval_wrapper", "o__Chitinophagales_eval_wrapper", "o__Cytophagales_eval_wrapper", "o__Flavobacteriales_eval_wrapper", "o__Sphingobacteriales_eval_wrapper"]

for file in files:
    os.system("python3 create_kameris_input.py "+file)
    os.system("python3 create_json.py "+file)


