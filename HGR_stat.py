import os
import pandas as pd
from Bio import SeqIO
import matplotlib.pyplot as plt



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
i = 0
for genome_file in os.listdir(genome_dir):
    # print(i)
    fasta_sequences = SeqIO.parse(open(os.path.join(genome_dir, genome_file)),'fasta')
    concat_seq = ''
    for fasta in fasta_sequences:
        _, sequence = fasta.id, str(fasta.seq)
        concat_seq += sequence
    size = len(concat_seq)
    sizes.append(size)
    GC_prop.append((concat_seq.count('G')+concat_seq.count('C'))/size)
    i += 1

print(sizes)
print(GC_prop)
plt.figure(0)
plt.hist(sizes, density=True)
plt.savefig('/home/w328li/MLDSP/outputs-HGR-r202/genome_size.png')
plt.figure(1)
plt.hist(GC_prop, density=True)
plt.savefig('/home/w328li/MLDSP/outputs-HGR-r202/GC_content.png')

    

