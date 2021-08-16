"""
Adds test dataset metafile for generating GC percentage, genome size and contig \
    count distribution plots

No command line arguments are required.
:param test_dir: testing directory
:param output_file: output file name in samples/
"""

from Bio import SeqIO
from Bio.SeqIO.PdbIO import CifAtomIterator
import pandas as pd
import os

test_dir = "/Users/wanxinli/Desktop/project.nosync/MLDSP-desktop/data/DS_10283_3009/genomes/"
output_file = "rumen_mag_metadata.csv"
df = pd.DataFrame(columns=['accession', 'contig_count', 'gc_percentage', 'genome_size'])
for file in os.listdir(test_dir):
    sequences = SeqIO.parse(open(test_dir+file+".fa"),'fasta') 
    contig_count = 0
    genome_size = 0
    gc_count = 0
    for fasta in sequences:
        _, sequence = fasta.id, str(fasta.seq)
        contig_count += 1
        genome_size += len(sequence)
        gc_count += sequence.count('C')+sequence.count('G')
    df = df.append({'accession': file, 'contig_count': contig_count, 'gc_percentage': \
        gc_count/genome_size, 'genome_size': genome_size})
print(df)



