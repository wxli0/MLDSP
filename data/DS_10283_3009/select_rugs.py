import sys
import pandas as pd 
import platform
from Bio import SeqIO
import os

# e.g. python3 select_rugs.py mags_g__CAG-791.json
sys.path.insert(0, '/Users/wanxinli/Desktop/project/MLDSP-desktop/data/preprocess/')
sys.path.insert(0, '/home/w328li/MLDSP/data/preprocess/')
from helpers import parse_json_test_input, prune_seq
import random
import numpy as np

taxon_place, taxon_name, frags_num, const_len, outdir = parse_json_test_input(sys.argv[1])
xlsx = pd.read_excel("41467_2018_3317_MOESM4_ESM.xlsx")
    
base_path = "/Users/wanxinli/Desktop/project/MLDSP-desktop/" # run locally
if platform.platform()[:5] == 'Linux':
    base_path = "/home/w328li/MLDSP/"
outdir_full = base_path+"samples/"+outdir
input_base_path = base_path+"data/DS_10283_3009/genomes/"

dirs = outdir.split("/")
for i in range(len(dirs)):
    cur_folder_path = base_path+"samples/"+'/'.join(dirs[:(i+1)])
    print(cur_folder_path)
    if not os.path.exists(cur_folder_path):
        os.makedirs(cur_folder_path)


# taxon = sys.argv[1] # e.g. genus
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
    cur_taxon  = taxon_names[i]
    results_table[cur_taxon] = results_table.apply(lambda row: row.GTDB_Tk_classification.split(";")[i], axis=1)

print(results_table)

select_files = []
for index, row in results_table.iterrows():
    # print(row[taxon])
    if row[taxon_place] == taxon_name:
        select_files.append(row['MAG'])
for file in select_files:
    fasta_sequences = SeqIO.parse(open(input_base_path+file+".fa"),'fasta') 
    entire_seq = ''
    entire_name = file
    entire_len = 0
    gap_num = frags_num-1
    for fasta in fasta_sequences:
        _, sequence = fasta.id, str(fasta.seq)
        sequence_real = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
        entire_seq += "O"+sequence
        entire_len += len(sequence_real)
    gap_remaining_len = entire_len - frags_num*const_len
    print("entire_len is:", entire_len)
    gap_lens = []
    if gap_remaining_len < 0:
        print("INFO: len is", entire_len)
        print("INFO: "+file+" is removed")
    while gap_num > 0:
        cur_gap_len = random.randint(0, gap_remaining_len)
        gap_lens.append(cur_gap_len)
        gap_remaining_len -= cur_gap_len
        gap_num -=1
    cur_fna_path = outdir_full+"/"+entire_name+".fasta"
    
    seq_remaining_len = entire_len-frags_num*const_len-np.sum(gap_lens)
    random_start = random.randint(0, seq_remaining_len)
    for i in range(frags_num):
        cur_seq, random_start = prune_seq(entire_seq, const_len, random_start)
        append_write = 'a'
        if i == 0:
            append_write = 'w'
        print("i is:", i)
        out_file= open(cur_fna_path, append_write)
        out_file.write(">"+entire_name+str(i)+"\n")
        out_file.write(cur_seq+"\n")
        out_file.close()


