import sys 
import os 
from Bio import SeqIO

dir = sys.argv[1]
dir_split = dir+"_200000"
os.mkdir(dir_split)
for sub_dir in os.listdir(dir):
    os.mkdir(os.path.join(dir_split, sub_dir))
    for file in os.listdir(os.path.join(dir, sub_dir)):
        file_short = file
        if file.endswith('.fa'):
            file_short = file[:-3]
        elif file.endswith('.fasta'):
            file_short = file[:-6]
        fasta_sequences = SeqIO.parse(open(os.path.join(dir, sub_dir, file)),'fasta')
        mode = 'w'
        total_len = 0
        for fasta in fasta_sequences:
            total_len += len(sequence)
            id, sequence = fasta.id, str(fasta.seq) 
            out_file= open(os.path.join(dir_split, sub_dir, file), mode=mode)
            out_file.write(">"+id+"\n")
            out_file.write(sequence+"\n")
            out_file.close()
            mode = 'a'
            if total_len >= 2000000:
                break