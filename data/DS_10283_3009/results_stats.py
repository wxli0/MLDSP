import pandas as pd 
import sys
import operator

# one_taxon = sys.argv[1] # e.g. genus
# taxon_name = sys.argv[2] # e.g. g__Prevotella
results_table = pd.read_excel("paper_results.xlsx", sheet_name = "Table S5", skiprows = [0,1])
results_table = results_table[['MAG', 'GTDB_Tk_classification']]
taxon_num = 7
print(results_table)
taxon_names = ['domain', 'phylum', 'class', 'order', 'family', 'genus', 'species']
for index, row in results_table.iterrows():
    taxon_path = row['GTDB_Tk_classification'].split(';')
    taxon_path += ['NA'] * (taxon_num-len(taxon_path))
    results_table.at[index, 'GTDB_Tk_classification'] = ";".join(taxon_path)
    
for i in range(len(taxon_names)):
    taxon  = taxon_names[i]
    results_table[taxon] = results_table.apply(lambda row: row.GTDB_Tk_classification.split(";")[i], axis=1)

print(results_table)

# to_print = []
# for index, row in results_table.iterrows():
#     # print(row[taxon])
#     if row[one_taxon] == taxon_name:
#         to_print.append(row['MAG'])

# print(to_print)
# print(len(to_print))

print(results_table['genus'])
dict = {}
for s in list(results_table['genus']):
    if s in dict:
        dict[s] += 1
    else:
        dict[s] = 1

sorted_dict = sorted(dict.items(), key=lambda x: x[1], reverse=True)
print(sorted_dict)



