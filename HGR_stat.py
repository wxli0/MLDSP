import os
import pandas as pd
from Bio import SeqIO


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
for genome_file in genome_dir:
    print(os.path.join(genome_dir, genome_file))
    fasta_sequences = SeqIO.parse(open(os.path.join(genome_dir, genome_file)),'fasta')
    concat_seq = ''
    for fasta in fasta_sequences:
        _, sequence = fasta.id, str(fasta.seq)
        concat_seq += sequence
    size = len(concat_seq)
    sizes.append(size)
    GC_prop.append((concat_seq.count('G')+concat_seq.count('C'))/size)

print(sizes)
print(GC_prop)

    

