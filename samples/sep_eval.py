import os
import sys
import random
import math
import shutil

complete_dir = sys.argv[1]
shutil.copytree(complete_dir, complete_dir+'_train')
train_dir = complete_dir+'_train'
eval_dir= complete_dir+'_eval'
os.mkdir(eval_dir)

# create a new eval_dir
# put 20% data in train_dir into eval_dir
ratio = 0.2
for cluster in os.listdir(train_dir):
    fasta_files = os.listdir(os.path.join(train_dir, cluster))
    eval_files = random.sample(fasta_files, math.floor(len(fasta_files)*ratio))
    os.mkdir(os.path.join(eval_dir, cluster+'_eval'))
    for file in eval_files:
        os.rename(os.path.join(train_dir, cluster, file), os.path.join(eval_dir, cluster+'_eval', file))

