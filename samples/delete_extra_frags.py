import sys 
import os 
from Bio import SeqIO

dir = sys.argv[1]
dir_split = dir+"_200000"
os.mkdir(dir_split)
for file in os.listdir(dir):
    fasta_sequences = SeqIO.parse(open(os.path.join(dir, file)),'fasta')
    mode = 'w'
    total_len = 0
    for fasta in fasta_sequences:
        id, sequence = fasta.id, str(fasta.seq) 
        total_len += len(sequence)
        out_file= open(os.path.join(dir_split, file), mode=mode)
        out_file.write(">"+id+"\n")
        out_file.write(sequence+"\n")
        out_file.close()
        mode = 'a'
        if total_len >= 200000:
            break
    print(file, "done")