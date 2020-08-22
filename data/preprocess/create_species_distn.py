import os
import pandas as pd 


bac120_total = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/bac120_taxonomy.tsv", sep='\t|;', engine='python', header=None, index_col=None)
print(bac120_total)
index = 7
bac120_total = bac120_total[[0,7]]
bac120_total.columns = ['id','species']

print(bac120_total)

bac120_total = bac120_total.groupby('species')['id'].apply(lambda x: "%s" % ','.join(x))
print(bac120_total)

count = 0
for index, value in bac120_total.items():
    if len(value.split(",")) > 50:
        out_file= open('/h/wanxinli/MLDSP/data/preprocess/'+index+'_distn.txt',"a+")
        out_file.write(value)
        count += 1

print(count)