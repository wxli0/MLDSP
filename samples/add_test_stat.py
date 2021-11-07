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

test_dir = "/mnt/sda/DeepMicrobes-data/labeled_genome-r202/hgr_mags/d__Bacteria/"
output_file = "samples/ERP108418_metadata.csv"
df = pd.DataFrame(columns=['accession', 'contig_count', 'gc_percentage', 'genome_size'])
# df = pd.DataFrame()
for file in os.listdir(test_dir):
    if file.endswith('.fa') and not file.endswith('_1.fa') \
        and not file.endswith('_2.fa'):
        sequences = SeqIO.parse(open(test_dir+file),'fasta') 
        contig_count = 0
        genome_size = 0
        gc_count = 0
        for fasta in sequences:
            _, sequence = fasta.id, str(fasta.seq)
            contig_count += 1
            genome_size += len(sequence)
            gc_count += sequence.count('C')+sequence.count('G')
        # df.loc[-1] = [file, contig_count, gc_count/genome_size, genome_size] 
        df = df.append({'accession': file, 'contig_count': contig_count, 'gc_percentage': \
            gc_count/genome_size*100, 'genome_size': genome_size}, ignore_index=True)
print(df)

df.to_csv(output_file, index=False, header=True)



