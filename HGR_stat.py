import os
import pandas as pd
from Bio import SeqIO
import matplotlib.pyplot as plt
from matplotlib.ticker import PercentFormatter
import numpy as np

# compute taxon overview
S1_path = '/home/w328li/MLDSP/samples/Table_S1_new.csv'
S1 = pd.read_csv(S1_path, skiprows=0, header=0)
ranks = ['Domain', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species']
for rank in ranks:
    num = len(set(S1[rank]))
    print(rank+":", num)

# compute genome size, GC content
genome_dir = '/mnt/sda/DeepMicrobes-data/labeled_genome'
sizes = []
GC_prop = []
contig_counts = []
for genome_file in os.listdir(genome_dir):
    # print(i)
    fasta_sequences = SeqIO.parse(open(os.path.join(genome_dir, genome_file)),'fasta')
    concat_seq = ''
    contig_count = 0
    for fasta in fasta_sequences:
        _, sequence = fasta.id, str(fasta.seq)
        concat_seq += sequence
        contig_count += 1
    size = len(concat_seq)
    sizes.append(size)
    contig_counts.append(contig_count)
    GC_prop.append((concat_seq.count('G')+concat_seq.count('C'))/size*100)

S1['gc_percentage'] = GC_prop
S1['genome_size'] = sizes
S1['contig_count'] = contig_counts

S1.to_csv('/home/w328li/MLDSP/samples/Table_S1_new.csv', index=False, header=True)

    

