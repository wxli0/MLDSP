import sys 
import os 
from Bio import SeqIO


input_path = "/home/w328li/MLDSP/samples/rumen_mags/all/"
output_path = "/home/w328li/MLDSP/samples/rumen_mags/all_first/"

for file in os.listdir(input_path):
    fasta_sequences = SeqIO.parse(open(input_path+file),'fasta') 
    output_file_path = output_path+file
    out_file= open(output_path, 'w')
    out_file.write(">"+fasta_sequences[0].id+"\n")
    out_file.write(fasta_sequences[0].seq+"\n")
    out_file.close()
