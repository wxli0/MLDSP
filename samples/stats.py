from Bio import SeqIO
import sys
import re

input_file = sys.argv[1]

fasta_sequences = SeqIO.parse(open(input_file),'fasta') 
for fasta in fasta_sequences:
    name, sequence = fasta.id, str(fasta.seq)    
    print("Sequence length is:", len(sequence))
    A_count = sequence.count('A')
    T_count = sequence.count('T')
    C_count = sequence.count('C')
    G_count = sequence.count('G')
    O_count = sequence.count('O')
    print("A count is:", A_count)
    print("T count is:", T_count)
    print("C count is:", C_count)
    print("G count is:", G_count)
    print("O count is:", O_count)
    print(re.sub('A|C|T|G', '', sequence)
    invalid_count = len(sequence)-(A_count+C_count+T_count+G_count)
    print("invalid_count is:", invalid_count)  
