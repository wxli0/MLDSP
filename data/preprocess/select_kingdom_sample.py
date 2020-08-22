import csv
import pandas as pd
import os
import random
import shutil
import sys
import os

outdir = sys.argv[1]
# preprocess tsv file
bac120_total = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/bac120_taxonomy.tsv", sep='\t|;', engine='python', header=None, index_col=0)
bac120_total = bac120_total[[2]] # only id, and phyla columns

bac120_subset = pd.DataFrame(columns = ['id','phyla'])

existing_genomes = os.listdir("/h/wanxinli/MLDSP/data/release89/bacteria")
# print(len(existing_genomes))
i = 0
for eg in existing_genomes:
    genome_name = "_".join(eg.split("_")[:3])
    bac120_subset.loc[i] = [genome_name, bac120_total.loc[genome_name][2]]
    i += 1

# print(bac120_subset)
bac120_subset = bac120_subset.groupby('phyla')['id'].apply(lambda x: "%s" % ','.join(x))
# print(bac120_subset)
bac120_subset.to_csv("bac120_subset.csv", index=True)


ar122_total = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/ar122_taxonomy.tsv", sep='\t|;', engine='python', header=None, index_col=0)
ar122_total = ar122_total[[2]] # only id, and phyla columns

ar122_subset = pd.DataFrame(columns = ['id','phyla'])
existing_genomes = os.listdir("/h/wanxinli/MLDSP/data/release89/archaea")
print(existing_genomes)
i = 0
for eg in existing_genomes:
    print("eg is:", eg)
    if not eg.endswith('_genomic.fna.gz'):
        continue
    genome_name = "_".join(eg.split("_")[:eg.count('_')])
    ar122_subset.loc[i] = [genome_name, ar122_total.loc[genome_name][2]]
    i += 1

print(ar122_subset)
ar122_subset = ar122_subset.groupby('phyla')['id'].apply(lambda x: "%s" % ','.join(x))
print(ar122_subset)
ar122_subset.to_csv("ar120_subset.csv", index=True)

# get phyla distribution
bac_phyla_distn = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/bac_phyla_distn.csv", header=0)
count_sum = bac_phyla_distn[['count']].sum()
bac_phyla_distn[['count']] = bac_phyla_distn[['count']]/count_sum
print(bac_phyla_distn)


ar_phyla_distn = pd.read_csv("/h/wanxinli/MLDSP/data/preprocess/ar_phyla_distn.csv", header=0)
count_sum = ar_phyla_distn[['count']].sum()
ar_phyla_distn[['count']] = ar_phyla_distn[['count']]/count_sum
print(ar_phyla_distn)

# sample sequence id
# bacteria
sample_size = 400
sampled_seqs = []
for _, row in bac_phyla_distn.iterrows():
    phyla = row['phyla']
    print(phyla)
    sample_num = int(sample_size*row['count'])
    print(sample_num)
    seq_str = bac120_subset[phyla]
    seqs = seq_str.split(",") if seq_str else []
    print("seqs is:", seqs)
    sampled_seqs.extend(random.sample(seqs, sample_num))

print("sampled seqs length is:", len(sampled_seqs), sampled_seqs)

# copy sampled tar to a new folder
if os.path.exists("/h/wanxinli/MLDSP/data/samples/"+outdir):
    os.rmdir("/h/wanxinli/MLDSP/data/samples/"+outdir)

os.mkdir("/h/wanxinli/MLDSP/data/samples/"+outdir)
os.mkdir("/h/wanxinli/MLDSP/data/samples/"+outdir+"/bacteria")
os.mkdir("/h/wanxinli/MLDSP/data/samples/"+outdir+"/archaea")

for seq in sampled_seqs:
    shutil.copy("/h/wanxinli/MLDSP/data/release89/bacteria/"+seq+"_genomic.fna.gz",
    "/h/wanxinli/MLDSP/data/samples/"+outdir+"/bacteria")

# archaea
# sample sequence id
sampled_seqs = []
for _, row in ar_phyla_distn.iterrows():
    phyla = row['phyla']
    print(phyla)
    sample_num = int(sample_size*row['count'])
    print(sample_num)
    seq_str = ar122_subset[phyla]
    seqs = seq_str.split(",") if seq_str else []
    print("seqs is:", seqs)
    sampled_seqs.extend(random.sample(seqs, sample_num))

print("sampled seqs length is:", len(sampled_seqs), sampled_seqs)

# copy sampled tar to a new folder
for seq in sampled_seqs:
    shutil.copy("/h/wanxinli/MLDSP/data/release89/archaea/"+seq+"_genomic.fna.gz",
    "/h/wanxinli/MLDSP/data/samples/"+outdir+"/archaea")


