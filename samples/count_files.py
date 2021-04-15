import os
import sys
import platform
from Bio import SeqIO


folder = sys.argv[1]
total = 0
base_path = '/Users/wanxinli/Desktop/project/MLDSP-desktop/samples'
if platform.platform()[:5] == 'Linux':
    base_path = '/home/w328li/MLDSP/samples'
for dir in os.listdir(base_path+'/'+folder):
    file_num = len(os.listdir(base_path+'/'+folder+'/'+dir))
    total_len = 0
    total += file_num
    for file in os.listdir(base_path+'/'+folder+'/'+dir):
        fasta_sequences = SeqIO.parse(file, "fasta")
        for fasta in fasta_sequences:
            _, sequence = fasta.id, str(fasta.seq)
            total_len += len(sequence)
            count += 1
    print(dir+":", file_num, "and total_len:", total_len)
print("total number:", total)
