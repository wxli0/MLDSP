"""
Counts the total number of files and total sequence length in all subdirectories \
    in a folder

:param sys.argv[1]: folder. The folder to count subdirectory total files and \
    sequences lengths
:type sys.argv[1]: str
"""

from Bio import SeqIO
import os
import platform
import sys

folder = sys.argv[1]
total = 0
base_path = '.'
if platform.platform()[:5] == 'Linux':
    base_path = '.'
for dir in os.listdir(base_path+'/'+folder):
    file_num = len(os.listdir(base_path+'/'+folder+'/'+dir))
    total_len = 0
    total += file_num
    for file in os.listdir(base_path+'/'+folder+'/'+dir):
        fasta_sequences = SeqIO.parse(os.path.join(base_path, folder, dir, file), "fasta")
        for fasta in fasta_sequences:
            _, sequence = fasta.id, str(fasta.seq)
            total_len += len(sequence)
    print(dir+":", file_num, "files", "and total length:", total_len, "bp")
print("total number:", total)
