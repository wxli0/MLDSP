import pandas as pd 

rank = "species"
cluster_tsv = pd.read_excel("/Users/wanxinli/Desktop/project/MLDSP-desktop/outputs/gtdbtk/GTDB-Tk_classification.xlsx", header = 0, index_col = 0)
cluster_tsv['GTDB_taxonomy'] = cluster_tsv[["classification"]]


taxon_names = ['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species']
for i in range(len(taxon_names)):
    taxon  = taxon_names[i]
    cluster_tsv[taxon] = cluster_tsv.apply(lambda row: row.GTDB_taxonomy.split(";")[i], axis=1)
cluster_tsv = cluster_tsv.drop(columns=['GTDB_taxonomy'])
# cluster_tsv.to_csv("gtdb-taxon.csv", index=True)

print(cluster_tsv)

print("printing all", rank)
print(sorted(list(set(cluster_tsv[rank].tolist()))))