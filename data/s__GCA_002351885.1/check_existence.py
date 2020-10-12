from Bio import SeqIO
import os

mag_path = '/Users/wanxinli/Desktop/project/MLDSP-desktop/data/DS_10283_3009/genomes/RUG009.fa'

mag_seqs = SeqIO.parse(open(mag_path),'fasta') 
for seq1 in mag_seqs:
    _, mag_seq = seq1.id, str(seq1.seq)
    for file in os.listdir('.'):
        if file.endswith('.fna'):
            gtdb_seqs = SeqIO.parse(open(file),'fasta') 
            for seq2 in gtdb_seqs:
                print("enter this")
                _, gtdb_seq = seq2.id, str(seq2.seq)
                if gtdb_seqs == mag_seqs:
                    print("in GTDB")
                    exit(1)

# not in GTDB


