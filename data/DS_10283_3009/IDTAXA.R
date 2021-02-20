# load the DECIPHER library in R
library(DECIPHER)

# specify the path to the FASTA file (in quotes)
fas <- "genomes/RUG518.fa"

# load the sequences from the file
seqs <- readDNAStringSet(fas) # or readRNAStringSet

# remove any gaps (if needed)
seqs <- RemoveGaps(seqs)

# for help, see the IdTaxa help page (optional)
?IdTaxa

# load a training set object (trainingSet)
# see http://DECIPHER.codes/Downloads.html
load("GTDB_r95-mod_August2020.RData")

# classify the sequences
ids <- IdTaxa(seqs,
              trainingSet,
              strand="both", # or "top" if same as trainingSet
              threshold=0, # 60 (cautious) or 50 (sensible)
              processors=NULL) # use all available processors

# look at the results
print(ids)
plot(ids)