"""
Appends label (label) to the end of every sequence id in a specific fasta \
    formated file

Command line arguments:
:param sys.argv[1]: file. The file to add labels
:type sys.argv[1]: str
:param sys.argv[2]: label. The label to append 
:type sys.argv[2]: str
"""

from Bio import SeqIO
import sys


file = sys.argv[1]
label = sys.argv[2]

fasta_sequences = SeqIO.parse(open(file),'fasta')
append_write = 'w'
for fasta in fasta_sequences:
    header, sequence = fasta.id, str(fasta.seq)
    header += "|"+str(label)
    out_file= open(file[:-6]+"_w_label.fasta", append_write)
    out_file.write(">"+header+"\n")
    out_file.write(sequence+"\n")
    out_file.close()
    append_write = 'a'