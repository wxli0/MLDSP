import os
import shutil
import sys
import glob
from Bio import SeqIO

# argv[1] is the folder to manipulate (transform from MLDSP to Kameris)

input_folder = sys.argv[1]

src = '/home/w328li/MLDSP-desktop/samples/'+input_folder+'/'
dest = '/home/w328li/BlindKameris-desktop/data/'+input_folder+'/'

if os.path.exists(dest):
    shutil.rmtree(dest, ignore_errors=True)

shutil.copytree(src, dest)

for file in glob.glob(dest+'/*/*'):
    shutil.move(file, dest)

for file in glob.glob(dest+'/'+'?__*'):
    shutil.rmtree(file)

for file in os.listdir(dest):
    fna_path = dest+file
    fasta_sequences = SeqIO.parse(open(fna_path),'fasta') 
    final_seq = ''
    for fasta in fasta_sequences:
        name, sequence = fasta.id, str(fasta.seq)
        if final_seq != '':
            final_seq = 'N'+sequence
    out_file= open(fna_path,"a+")
    out_file.seek(0)
    out_file.truncate()
    out_file.write(">"+file+'.fasta'+"\n")
    out_file.write(final_seq)
