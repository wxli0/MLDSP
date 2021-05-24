import os 
import sys 
import pandas as pd

ver = 'r202'
df = pd.read_csv("sp_clusters_"+ver+".tsv", sep='\t', header = 0, index_col = 0)

taxon = pd.DataFrame()
taxon['Representative_genome'] = df.index.tolist()
index = 0
def get_target_col(tax_text):
    return tax_text.split(";")[index]

ranks = ['domain', 'phylum', 'class', 'order', 'family', 'genus']
for i in range(len(ranks)):
    rank = ranks[i]
    index = i
    taxon[rank] = df['GTDB_taxonomy'].apply(get_target_col).tolist()

taxon['species'] = df['GTDB_species'].tolist()
taxon = taxon.set_index(['Representative_genome'])

print(taxon)

taxon.to_csv('taxon-'+ver+'.csv')
