import sys
import pandas as pd 
import openpyxl
import os 

file = sys.argv[1]

pre_sheet_names = ["quadratic-svm-score1", "quadratic-svm-score2", 
"quadratic-svm-score3", "quadratic-svm-score4", "quadratic-svm-score5"]

df_merged = pd.read_excel(file, sheet_name = "quadratic-svm-score1", index_col=0)

for i in range(len(pre_sheet_names)-1):
    sheet = pre_sheet_names[i+1]
    df = pd.read_excel(file, sheet_name = sheet, index_col=1)
    df_merged = pd.concat([df_merged, df])

classes = df_merged.columns
for c in classes:
    index = classes.index(c)+1
    df = df.replace({'prediction': {index: c}, 'actual': {index: c}})

for c in classes:
    df_subset = df_merged.loc[df_merged['actual'] == c]
    df_subset.to_excel(file, sheet_name=c+"-b-p")

os.system("python3 add_softmax.py "+file_name+" "+sheet)



wb = openpyxl.load_workbook(file)
for sheet in pre_sheet_names:
    del wb[sheet]
wb.save(file)


