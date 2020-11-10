import pandas as pd 

cluster_tsv = pd.read_csv("/Users/wanxinli/Desktop/project/MLDSP-desktop/data/preprocess/sp_clusters.tsv", sep='\t', header = 0, index_col = None)
cluster_tsv = cluster_tsv[["GTDB_species", "GTDB_taxonomy"]]
cluster_tsv['GTDB_taxonomy'] = cluster_tsv['GTDB_taxonomy']+";"+cluster_tsv['GTDB_species']
cluster_tsv = cluster_tsv.drop(columns=['GTDB_species'])
cluster_tsv.drop_duplicates(subset=['GTDB_taxonomy'], keep=False)

taxon_names = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
for i in range(len(taxon_names)):
    taxon  = taxon_names[i]
    cluster_tsv[taxon] = cluster_tsv.apply(lambda row: row.GTDB_taxonomy.split(";")[i], axis=1)
cluster_tsv['kingdom'] = cluster_tsv.apply(lambda row: row.kingdom.replace("d__", "k__"), axis=1)
cluster_tsv = cluster_tsv.drop(columns=['GTDB_taxonomy'])
cluster_tsv.to_csv("taxon.csv", index=False)

# print(cluster_tsv)