import sys
import os
import pandas as pd 
import sys
import json 

taxon = sys.argv[1]
ver = sys.argv[2]

taxon_path = ("./data/preprocess/taxon-"+ver+".csv")

rank_names = ['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species']
rank = ''
next_rank = ''
if taxon.startswith('d'):
    next_rank = 'phylum'
    rank = 'domain'
elif taxon.startswith('p'):
    next_rank = 'class'
    rank = 'phylum'
elif taxon.startswith('c'):
    next_rank = 'order'
    rank = 'class'
elif taxon.startswith('o'):
    next_rank = 'family'
    rank = 'order'
elif taxon.startswith('f'):
    next_rank = 'genus'
    rank = 'family'
elif taxon.startswith('g'):
    next_rank = 'species'
    rank = 'genus'

gtdb_df = pd.read_csv(taxon_path, index_col=None, header=0)

clusters = list(set(gtdb_df.loc[gtdb_df[rank] == taxon][next_rank].tolist()))

sample_dict = {
    "tax_name": next_rank,
    "use_factor": True,
    "sample_factor": 1,
    "use_const_len": True,
    "const_len": 100000,
    "frags_num": 4,
    "cluster_names": clusters,
    "outdir": taxon,
    "rep_time": 20
}



sample_dict_path = os.path.join('./data/preprocess/non-clade-exclusion-'+ver+'/'+taxon+".json")
with open(sample_dict_path, 'w') as json_file:
    json.dump(sample_dict, json_file)