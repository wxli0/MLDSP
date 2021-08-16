"""
Makes Task 1 (HGR) training dataset from Genus in \
    https://github.com/MicrobeLab/DeepMicrobes-data/tree/master/training_genomes

Example: python3 make_HGR_training_set Phylum
"""

import os 
import pandas as pd 
import shutil
import sys 


true_path = "Table_S1.csv"
S1 = pd.read_csv(true_path, skiprows=0, header=1)
print(S1)

rank=sys.argv[1]
pos = list(S1[rank])
cleaned_pos = list(set([x for x in pos if str(x) != 'nan']))
cleaned_pos.sort()
# print(cleaned_pos)
# print(list(set(cleaned_pos)).sort())

next_rank_dict = {
    'Phylum': 'Class',
    'Class': 'Order',
    'Order': 'Family',
    'Family': 'Genus'
}

next_rank = next_rank_dict[rank]
parent_child_dict = {}
next_rank_child_dict = {}
for item in cleaned_pos:
    S1_subset = S1.loc[S1[rank] == item]
    next_rank_pos = list(S1_subset[next_rank])
    cleaned_next_rank_pos = list(set([x for x in next_rank_pos if str(x) != 'nan']))
    cleaned_next_rank_pos.sort()
    # print(item+":", cleaned_next_rank_pos)
    parent_child_dict[item] = cleaned_next_rank_pos
    for next_rank_item in next_rank_pos:
        S1_subset_next_rank = S1.loc[S1[next_rank] == next_rank_item]
        next_rank_genera_list = list(S1_subset_next_rank['Genus'])
        cleaned_next_rank_genera = list(set([x for x in next_rank_genera_list if str(x) != 'nan']))
        cleaned_next_rank_genera.sort()
        next_rank_child_dict[next_rank_item] = cleaned_next_rank_genera


print(parent_child_dict)
print(next_rank_child_dict)
parent_prefix = rank[0].lower()+"__"
child_prefix = next_rank[0].lower()+"__"
for parent, children in parent_child_dict.items():
    os.mkdir("labeled_genome_genus/"+parent_prefix+parent)
    if len(children) == 0:
        continue
    for child in children:
        pos_genera = next_rank_child_dict[child]
        if len(pos_genera) == 0:
            continue 
        os.mkdir("labeled_genome_genus/"+parent_prefix+parent+"/"+child_prefix+child)
        for genus in pos_genera:
            if os.path.isfile("labeled_genome_genus/label_"+genus+".fa"):
                shutil.copyfile("labeled_genome_genus/label_"+genus+".fa", \
                    "labeled_genome_genus/"+parent_prefix+parent+"/"+child_prefix+child+"/"+"label_"+genus+".fa")