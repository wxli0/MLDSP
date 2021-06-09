import os 
import sys 
import pandas as pd 
import shutil

# e.g. python3 make_HGR_training_set Phylum
true_path = "Table_S1_new.csv"
S1 = pd.read_csv(true_path, skiprows=0, header=0)
print(S1)

rank=sys.argv[1]
pos = list(S1[rank])
cleaned_pos = list(set([x for x in pos if str(x) != 'nan']))
cleaned_pos.sort()
# print(cleaned_pos)
# print(list(set(cleaned_pos)).sort())

next_rank_dict = {
    'Domain': 'Phylum',
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
        next_rank_genome_list = list(S1_subset_next_rank['Genome'])
        cleaned_next_rank_genome = list(set([x for x in next_rank_genome_list if str(x) != 'nan']))
        cleaned_next_rank_genome.sort()
        next_rank_child_dict[next_rank_item] = cleaned_next_rank_genome


print(parent_child_dict)
print(next_rank_child_dict)
parent_prefix = ""
child_prefix = ""
for parent, children in parent_child_dict.items():
    os.mkdir("/mnt/sda/DeepMicrobes-data/labeled_genome-r202/"+parent_prefix+parent)
    if len(children) == 0:
        continue
    for child in children:
        pos_genome = next_rank_child_dict[child]
        if len(pos_genome) == 0:
            continue 
        os.mkdir("/mnt/sda/DeepMicrobes-data/labeled_genome-r202/"+parent_prefix+parent+"/"+child_prefix+child)
        for genome in pos_genome:
            if os.path.isfile("/mnt/sda/DeepMicrobes-data/labeled_genome/"+genome+".fa"):
                shutil.copyfile("/mnt/sda/DeepMicrobes-data/labeled_genome/"+genome+".fa", \
                    "/mnt/sda/DeepMicrobes-data/labeled_genome-r202/"+parent_prefix+parent+"/"+child_prefix+child+"/"+genome+".fa")