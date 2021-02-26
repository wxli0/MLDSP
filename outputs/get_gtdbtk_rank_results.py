import pandas as pd 

df = pd.read_excel("/Users/wanxinli/Desktop/project/MLDSP-desktop/outputs/gtdbtk/gtdbtk.bac120.summary.xls", sheet_name="gtdbtk.bac120.summary",header=0)
df['genus']=df.apply(lambda row: row.pplacer_taxonomy.split(";")[5],axis=1)

print(set(list(df['genus'])))