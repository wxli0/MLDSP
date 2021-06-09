import os
import sys 
import numpy as np

dir = sys.argv[1]
ver = sys.argv[2]
data_type = sys.argv[3]
if data_type == 'GTDB':
    if dir == 'root':
        bac_files = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Bacteria')
        delete_bac = np.random.choice(bac_files, int(len(bac_files)*0.9), replace=False)
        for file in delete_bac:
            os.remove('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Bacteria/'+file)

        arc_files = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Archaea')
        delete_arc = np.random.choice(arc_files, int(len(arc_files)*0.9), replace=False)
        for file in delete_arc:
            os.remove('/mnt/sda/MLDSP-samples-'+ver+'/root/d__Archaea/'+file)
    if dir.startswith('d__') or dir == 'p__Actinobacteriota' or dir == 'p__Bacteroidota' \
        or dir == 'p__Firmicutes' \
        or dir == 'p__Firmicutes_A' or dir == 'p__Cyanobacteria' or dir == 'c__Actinomycetia' \
            or dir == 'c__Bacteroidia' or dir == 'c__Clostridia' or dir == 'o__Actinomycetales' \
                or dir == 'o__Bacteroidales' or dir == 'o__Lachnospirales' or dir == 'c__Bacilli' \
                    or dir == 'p__Proteobacteria' or dir == 'c__Alphaproteobacteria':
        arc_dirs = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/'+dir)
        for d in arc_dirs:
            all_files = os.listdir('/mnt/sda/MLDSP-samples-'+ver+'/'+dir+'/'+d)
            if len(all_files) < 100:
                continue
            delete_files = np.random.choice(all_files, int(len(all_files)*0.9), replace=False)
            for f in delete_files:
                os.remove('/mnt/sda/MLDSP-samples-'+ver+'/'+dir+'/'+d+'/'+f)
elif data_type == 'HGR':
    if dir.startswith('d__Bacteria') or dir.startswith('p__Firmicutes_A') or dir.startswith('p__Bacteroidota'):
        arc_dirs = os.listdir('/mnt/sda/DeepMicrobes-data/labeled_genome-'+ver+'/'+dir)
        for d in arc_dirs:
            all_files = os.listdir('/mnt/sda/DeepMicrobes-data/labeled_genome-'+ver+'/'+dir+'/'+d)
            if len(all_files) < 100:
                continue
            delete_files = np.random.choice(all_files, int(len(all_files)*0.9), replace=False)
            for f in delete_files:
                os.remove('/mnt/sda/DeepMicrobes-data/labeled_genome-'+ver+'/'+dir+'/'+d+'/'+f)