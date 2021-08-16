"""
Prepares training dataset for DeepMicrobes by combining files with the same labels \
    into one file

No command line argments are required.
"""

import os

dir = '/mnt/sda/MLDSP-samples-r202/dm_species/'
for sub_dir in os.listdir(dir):
    os.system("cat '"+sub_dir+"'/*.fna >  '"+sub_dir+"'_combined.fna")