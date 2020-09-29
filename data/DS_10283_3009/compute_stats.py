import glob
import os
from Bio import SeqIO


os.chdir("genomes/")
count = 0
total_len = 0
for file in glob.glob("*.fa"):
    fasta_sequences = SeqIO.parse(open(file),'fasta')
    for fasta in fasta_sequences:
        _, sequence = fasta.id, str(fasta.seq)
        total_len += len(sequence)
        count += 1
print("mean is:", total_len/count)



