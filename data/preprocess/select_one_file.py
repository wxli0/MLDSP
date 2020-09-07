import sys

# argv[1]: input file
# argv[2]: output file

input_file = sys.argv[1] # id in selected_genomes
output_file = sys.argv[2]

def select_one_file(id, cluster_dir_full, const_len, frags_num):
   
    block1 = id[3:6]
    block2= id[7:10]
    block3 = id[10:13]
    block4 = id[13:16]
    print(block1, block2,block3, block4)
    partial_url = base_url+block1+'/'+block2+'/'+block3+'/'+block4 +'/'
    try:
        partial_url_dirs =  list_fd(partial_url)
        block5 = partial_url_dirs[1]
        last_index = block5.split("/", 9)[-1][:-1]
        download_url = block5+last_index+'_genomic.fna.gz'
        dest = cluster_dir_full+'/'+last_index+'_genomic.fna.gz'
        urllib.request.urlretrieve(download_url, dest)
        f = gzip.open(dest, 'r')
        file_content = f.read()
        file_content = file_content.decode('utf-8')
        fna_path = cluster_dir_full+'/'+last_index+"_genomic.fna"
        f_out = open(cluster_dir_full+'/'+last_index+"_genomic.fna", 'w+')
        f_out.write(file_content)
        f.close()
        f_out.close()
        os.remove(dest)

        fasta_sequences = SeqIO.parse(open(fna_path),'fasta') 
        max_len = 0
        max_seq = ''
        max_name = id+'.fasta'
        ######## tmp fix for now ############
        for fasta in fasta_sequences:
            name, sequence = fasta.id, str(fasta.seq)
            sequence_real = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
            # if len(sequence_real) > max_len:
            #     max_len = len(sequence_real)
            #     max_seq = sequence # max_seq should contain 'X'
            #     max_name = name
            print("max_len is:", max_len)
            print("sequence_real len is:", len(sequence_real))
            # if len(sequence_real) > max_len:
            #     max_name = name
            if sequence is None:
                continue
            max_len += len(sequence_real)
            max_seq += ('N'+ sequence)
    
            if max_len < (frags_num*const_len):
                os.remove(fna_path)
                print("INFO: len is", max_len)
                print("INFO: "+fna_path+" is removed")
                continue
            else:
                print("before download_const_genome")
                download_const_genome(max_len, max_seq, max_name, frags_num, const_len, cluster_dir_full, fna_path)

    except Exception as e:
        print("ERROR:", "an error has occurred")
        print(e)
        pass
