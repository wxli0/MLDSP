from Bio import SeqIO
from bs4 import BeautifulSoup
import gzip
import json
import numpy as np
import os
import random
import requests
import urllib.request

random.seed(0)

base_url = 'https://ftp.ncbi.nlm.nih.gov/genomes/all/'


def list_fd(url, ext=''):
    """
    Lists all files and directorys in url (url) ending with an extension (ext)

    :param url: requested url
    :type url: str
    :param ext: required extension, default ''
    :type ext: str
    """

    page = requests.get(url).text
    print(page)
    soup = BeautifulSoup(page, 'html.parser')
    ret = []
    
    return [os.path.join(url, node.get('href')) for node in soup.find_all('a') if node.get('href').endswith(ext)]


def find_start_point(entire_seq, seq_len):
    """
    Finds the position range for the start point on a sequence (entire_seq) to \
        get a fragment of length seq_len
    
    :param entire_seq: entire sequence
    :type entire_seq: str
    :param seq_len: length the requested fragments
    :type seq_len: int
    """

    entire_seq_len = len(entire_seq)
    count = 0
    for i in reversed(range(entire_seq_len)):
        if entire_seq[i] in 'ACGT':
            count += 1
        if count == seq_len:
            break
    return i


def prune_seq(entire_seq, seq_len, start_point):
    """
    Prunes sequence entire_seq from start point (start_point) to a fragment of \
        length seq_len
    
    :param entire_seq: sequence to prune
    :type entire_seq: str
    :param seq_len: length of the requested fragment
    :type seq_len: int
    :param start_point: start point on entire_seq
    :type start_point: int
    """

    entire_seq_len = len(entire_seq)
    count = 0
    i = 0
    for i in range(start_point, entire_seq_len):
        if entire_seq[i] in 'ACGT':
            count += 1
        if count == seq_len:
            break
    return entire_seq[start_point:(i+1)], i+1


def download_genomes(selected_genome_ids, cluster_dir_full, lower, upper, \
    use_const_len, const_len, frags_num, alter, rep_time, full=False):
    """
    Downloads genomes in selected_genome_ids into a directory (cluster_dir_full). \
        The downloaded files are suffixed with alter. 
        The genomes downloaded conforms to properties: lower length (lower); \
            upper length (upper); use constant length or not (use_const_len); \
                if true, constant length (const_len); number of fragments (frags_\
                    num), number of repetive times (rep_time); full genomes or not \
                        (full)
    :param selected_genome_ids: list of genomes to download
    :type selected_genome_ids: List[str]
    :param cluster_dir_full: directory to download
    :type cluster_dir_full: str
    :param lower: lower bound on the downloaded sequence length
    :type lower: int
    :param upper: upper bound on the donwloaded sequence length
    :type upper: int
    :param use_const_len: the downloaded fragments are of the same length or not
    :type use_const_len: Bool
    :param frags_num: number of fragments per genome
    :type frags_num: int
    :param alter: if provided, the downloaded genome files are suffixed with alter
    :type alter: str
    :param rep_time: number of repetive times to sample per genome
    :type rep_time: int
    :param full: download full genomes or fragments of genomes, default False
    :type full: Bool
    """

    for id in selected_genome_ids:
            block1 = id[3:6]
            block2= id[7:10]
            block3 = id[10:13]
            block4 = id[13:16]
            print("base_url is:", base_url)
            print("blocks are:", block1, block2,block3, block4)
            partial_url = os.path.join(base_url,block1,block2,block3,block4)
            print("partial_url is:", partial_url)
            try:
                partial_url_dirs =  list_fd(partial_url)
                block5 = partial_url_dirs[1]
                print("partial_url_dirs is:", partial_url_dirs)
                # print("block5 is:", block5)
                last_index = block5.split("/", 9)[-1][:-1]
                download_url = block5+last_index+'_genomic.fna.gz'
                print("download_url is:", download_url)
                dest = os.path.join(cluster_dir_full, last_index+'_genomic.fna.gz')
                urllib.request.urlretrieve(download_url, dest)
                f = gzip.open(dest, 'r')
                file_content = f.read()
                file_content = file_content.decode('utf-8')
                fna_path = os.path.join(cluster_dir_full, last_index+"_genomic.fna")
                # print("fna_path is:", fna_path)
                f_out = open(os.path.join(cluster_dir_full, last_index+"_genomic.fna"), 'w+')
                f_out.write(file_content)
                f.close()
                f_out.close()
                os.remove(dest)

                if not full:
                    print("enter not full")
                    fasta_sequences = SeqIO.parse(open(fna_path),'fasta') 
                    max_len = 0
                    max_seq = ''
                    max_name = id
                    ######## tmp fix for now ############
                    for fasta in fasta_sequences:
                        _, sequence = fasta.id, str(fasta.seq)
                        sequence_real = ''.join( c for c in sequence if  c in 'ACGT') # prune irrelevant chars
                        # if len(sequence_real) > max_len:
                        #     max_len = len(sequence_real)
                        #     max_seq = sequence # max_seq should contain 'X'
                        #     max_name = name
                        # print("max_len is:", max_len)
                        # print("sequence_real len is:", len(sequence_real))
                        # if len(sequence_real) > max_len:
                        #     max_name = name
                        if sequence is None:
                            continue
                        max_len += len(sequence_real)
                        max_seq += ('O'+ sequence)
                    print("complete concate sequences")
                    if not use_const_len: # use variable length in [lower, upper]
                        if max_len < lower:
                            os.remove(fna_path)
                            print("INFO: len is", max_len)
                            print("INFO: "+fna_path+" is removed")
                            continue
                        else:
                            download_variable_genome(max_len, max_seq, max_name, lower, upper, frags_num, cluster_dir_full, fna_path)
                    else:
                        print("enter right clause")
                        if max_len < (frags_num*const_len):
                            os.remove(fna_path)
                            print("INFO: len is", max_len)
                            print("INFO: "+fna_path+" is removed")
                            continue
                        else:
                            print("before download_const_genome")
                            download_const_genome(max_len, max_seq, max_name, frags_num, const_len, cluster_dir_full, fna_path, alter, rep_time)

            except Exception as e:
                print("ERROR:", "an error has occurred")
                print(e)
                pass


def download_variable_genome(max_len, max_seq, max_name, lower, upper, frags_num, cluster_dir_full, fna_path):
    """
    Downloads genomes of variable length. Helper function for download_genomes. \
        Uses a subset of parameters from download_genomes
    
    :param max_len: length of the valid ('ATCG') sequences 
    :type max_len: int
    :param max_seq: sequences in the original genomes file concatenated by 'O'
    :type max_seq: str
    :param max_name: genome id
    :type max_name: str
    :param fna_path: path for the downloaded full genome file
    :type fna_path: str
    """

    base = 0
    for i in range(frags_num):
        seq_len = random.randint(lower, min(upper, max_len))
        tmp = find_start_point(max_seq, seq_len)
        random_start = random.randint(0, tmp)
        cur_max_seq = prune_seq(max_seq, seq_len, random_start)                    
        cur_fna_path = os.path.join(cluster_dir_full, max_name+str(base+i)+".fasta")
        if i == 0:
            while os.path.exists(cur_fna_path):
                base += 1
                cur_fna_path = os.path.join(cluster_dir_full, max_name+str(base+i)+".fasta")
        out_file= open(cur_fna_path,"a+")
        out_file.seek(0)
        out_file.truncate()
        out_file.write(">"+max_name+str(i)+"\n")
        out_file.write(cur_max_seq)
    os.remove(fna_path)


def download_const_genome(max_len, max_seq, max_name, frags_num, const_len, cluster_dir_full, fna_path, alter, rep_time):
    """
    Downloads genomes of constant length. Helper function for download_genomes. \
        Uses a subset of parameters from download_genomes
    
    :param max_len: length of the valid ('ATCG') sequences 
    :type max_len: int
    :param max_seq: sequences in the original genomes file concatenated by 'O'
    :type max_seq: str
    :param max_name: genome id
    :type max_name: str
    :param fna_path: path for the downloaded full genome file
    :type fna_path: str
    """

    gap_num = frags_num-1
    gap_remaining_len = max_len - frags_num*const_len
    gap_lens = []
    while gap_num > 0:
        cur_gap_len = random.randint(0, gap_remaining_len)
        gap_lens.append(cur_gap_len)
        gap_remaining_len -= cur_gap_len
        gap_num -=1
    seq_remaining_len = max_len-frags_num*const_len-np.sum(gap_lens)
    random_start = random.randint(0, seq_remaining_len)
    print("max_name is:", max_name)

    for cur_rep in range(rep_time):
        cur_fna_path = os.path.join(cluster_dir_full, max_name+"_"+str(cur_rep)+".fasta")
        if alter is not None:
            cur_fna_path = os.path.join(cluster_dir_full, max_name+"_"+str(cur_rep)+"_"+alter+".fasta")

        i = 0
        for i in range(frags_num):
            cur_seq, random_start = prune_seq(max_seq, const_len, random_start)
            append_write = 'a'
            if i == 0:
                append_write = 'w'
            # print("i is:", i)
            out_file= open(cur_fna_path, append_write)
            out_file.write(">"+max_name+str(i)+"\n")
            out_file.write(cur_seq+"\n")
            out_file.close()
    # print('before remove')
    os.remove(fna_path)
    # print("after remove")

# parse json input
def parse_json_input(input_file_name):
    """
    Parses the fields in input file (input_file_name). Potential fields are: \
        tax_name, use_factor, cluster_names, use_const_len, use_factor, \
            sample_factor, sample_size, upper, lower, frags_num, const_len, \
                sample_factor, id, alter, outdir, rep_time. This is used for \
                    downloading GTDB genomes
    
    :param input_file_name: file path of the input json 
    :type input_file_name: str
    """

    json_input = json.load(open(input_file_name))
    sample_factor = 0
    sample_size = 0
    tax_name = json_input['tax_name']
    use_factor = json_input['use_factor']
    cluster_names = json_input['cluster_names']
    frags_num = 1
    use_const_len = json_input['use_const_len']
    const_len = None
    id = None
    alter = None
    outdir = None
    rep_time = 1

    if json_input['use_factor']:
        sample_factor = json_input['sample_factor']
    else:
        sample_size = json_input['sample_size']
    cluster_num = len(cluster_names)
    lower = 1e5
    upper = 2e5
    if 'lower' in json_input:
        lower = json_input['lower']
    if 'upper' in json_input:
        upper = json_input['upper']
    if 'frags_num' in json_input:
        frags_num = json_input['frags_num']
    if use_const_len:
        const_len = json_input['const_len']
    if use_factor:
        sample_factor = json_input['sample_factor']
    if 'id' in json_input:
        id = json_input['id']
    if 'alter' in json_input:
        alter = json_input['alter']
    if 'outdir' in json_input:
        outdir = json_input['outdir']
    if 'rep_time' in json_input:
        rep_time = json_input['rep_time']
    return sample_factor, sample_size, tax_name, use_factor, cluster_num, \
        cluster_names, int(lower), int(upper), use_const_len, const_len, \
            frags_num, alter, id, outdir, rep_time

def parse_json_test_input(input_file_name):
    """
        Parses the fields in input file (input_file_name). Potential fields are: \
        tax_name, use_factor, cluster_names, use_const_len, use_factor, \
            sample_factor, sample_size, upper, lower, frags_num, const_len, \
                sample_factor, id, alter, outdir, rep_time. This is used for \
                    downloading selecting and pruning rumen mag genomes)
    
    :param input_file_name: file path of the input json 
    :type input_file_name: str
    """

    json_input = json.load(open(input_file_name))
    return json_input['taxon_place'], json_input['taxon'], json_input['frag_num'], \
        json_input['const_len'], json_input['outdir']