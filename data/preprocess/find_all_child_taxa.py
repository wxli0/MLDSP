"""
Finds all species taxa name of the input genera

Used for sampling GTDB_subset
"""

import os
import pandas as pd
import sys
sys.path.insert(0, '../../')

import config

tax_name = 'genus'
next_tax_name = 'species'
indices = {"domain":0, "phylum":1, "class":2, "order":3, "family":4, "genus":5}
next_taxs = {"domain":"phylum", "phylum":"class", "class":"order", "order":"family", "family":"genus", "genus":"species"}
index_names = {"domain": 'd__', 'phylum':'p__','class':'c__','order':'o__',"family":"f__", "genus":"g__"}

index = indices[tax_name]
next_tax_name = next_taxs[tax_name]

cluster_tsv = pd.read_csv("sp_clusters_r202.tsv", sep='\t', header = 0, index_col = None)
cluster_tsv = cluster_tsv[['Representative_genome', 'GTDB_taxonomy', 'GTDB_species']]

def get_target_col(tax_text):
    return tax_text.split(";")[index]

def get_target_next_col(tax_text):
    return tax_text.split(";")[index+1]

cluster_tsv[tax_name] = cluster_tsv['GTDB_taxonomy'].apply(get_target_col)
if tax_name == "genus":
    cluster_tsv.rename(columns = {'GTDB_species':'species'}, inplace = True)
else:
    cluster_tsv[next_tax_name] = cluster_tsv['GTDB_taxonomy'].apply(get_target_next_col)

cluster_tsv = cluster_tsv.drop(['GTDB_taxonomy'], axis=1)
# print(cluster_tsv)


GTDB_gt_path = os.path.join(config.MT_MAG_path, "outputs-GTDB-r202-archive1/GTDB-r202-prediction-full-path.csv")
gt_df = pd.read_csv(GTDB_gt_path, index_col=0, header=0, dtype = str)
cluster_names = list(set(gt_df['gtdb-tk-genus']))
if 'g__' in cluster_names:
    cluster_names.remove('g__')

species_subset = []
for cluster_name in cluster_names:
    cluster_tsv_cur = cluster_tsv.loc[cluster_tsv[tax_name] == cluster_name]
    cluster_tsv_cur = cluster_tsv_cur.drop([tax_name], axis=1)
    cluster_tsv_cur = cluster_tsv_cur.groupby(next_tax_name)['Representative_genome'].apply(list).reset_index().set_index(next_tax_name)
    # print(list(cluster_tsv_cur.index))
    species_subset.extend(list(cluster_tsv_cur.index))
species_subset = list(set(species_subset))
print("all species is:", species_subset)
print("length is:", len(species_subset))


# check if all GTDB-Tk predicted species are in species subset
predicted_species = list(set(gt_df['gtdb-tk-species']))
for species in predicted_species:
    if species not in species_subset:
        print("ERROR:", species, "is not in species_subset")