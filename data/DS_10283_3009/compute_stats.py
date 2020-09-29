import glob
import os
from Bio import SeqIO
import pandas as pd


# os.chdir("genomes/")
# count = 0
# total_len = 0
# for file in glob.glob("*.fa"):
#     fasta_sequences = SeqIO.parse(open(file),'fasta')
#     for fasta in fasta_sequences:
#         _, sequence = fasta.id, str(fasta.seq)
#         total_len += len(sequence)
#         count += 1
# print("mean is:", total_len/count)


# compute taxon distribution in 913 MAGS
# xlsx = pd.read_excel("41467_2018_3317_MOESM4_ESM.xlsx")
# est_taxons = xlsx['Estimated taxon']
# print(est_taxons)
# taxon_dict = {}
# for t in est_taxons:
#     if t not in taxon_dict:
#         taxon_dict[t] = 1
#     else:
#         taxon_dict[t] += 1
# print(taxon_dict)

# get file names of a taxon
xlsx = pd.read_excel("41467_2018_3317_MOESM4_ESM.xlsx")
file_names = []
for index, row in xlsx.iterrows():
    if row['Estimated taxon'] == 'g__Olsenella':
        file_names.append(row['RUG'])
    
print(file_names)

for file in file_names:
    print(file)
    fasta_sequences = SeqIO.parse(open('genomes/'+file+'.fa'),'fasta') 
    max = 0
    for fasta in fasta_sequences:
        _, sequence = fasta.id, str(fasta.seq)
        if len(sequence) > max:
            max = len(sequence)
    print(max)