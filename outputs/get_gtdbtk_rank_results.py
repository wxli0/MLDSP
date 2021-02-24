import pandas as pd 

df = pd.read_excel("/Users/wanxinli/Desktop/project/MLDSP-desktop/outputs/gtdbtk/gtdbtk.ar122.summary.xls", sheet_name="gtdbtk.ar122.summary",header=0)
df['phylum']=df.apply(lambda row: row.pplacer_taxonomy.split(";")[1],axis=1)

print(set(list(df['phylum'])))