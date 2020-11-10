import pandas as pd


taxon_names = ['kingdom', 'phylum', 'class', 'order', 'family', 'genus', 'species']
new_data = pd.DataFrame(columns= taxon_names, index=['RUG'])
print(new_data)
taxon_csv = pd.read_csv("taxon.csv", index_col=None, header=0)
xlsx = pd.read_excel("41467_2018_3317_MOESM4_ESM.xlsx")
xlsx = xlsx[['RUG','Estimated taxon']]
for i in range(len(xlsx['Estimated taxon'])):
    et = xlsx['Estimated taxon'][i]
    if et[1:3] != "__":
        xlsx.at[i,'Estimated taxon']= 's__'+et

kingdom_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('k__'), axis=1)]
phylum_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('p__'), axis=1)]
class_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('c__'), axis=1)]
order_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('o__'), axis=1)]
family_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('f__'), axis=1)]
genus_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('g__'), axis=1)]
species_data = xlsx[xlsx.apply(lambda x: x['Estimated taxon'].startswith('s__'), axis=1)]
mismatch = []
for i in range(len(taxon_names)):
    taxon = taxon_names[i]
    exec("data = %s_data"%(taxon))
    taxon_w_index = taxon_csv.drop(columns=taxon_names[i+1:])
    taxon_w_index = taxon_w_index.set_index(taxon)
    for index, row in data.iterrows():
        est_taxon = row['Estimated taxon']
        if est_taxon not in taxon_w_index.index and est_taxon not in mismatch:
            mismatch.append(est_taxon)

print(mismatch)

