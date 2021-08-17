# R script for generating training/test dataset GC percentage, genome size, contig count

tab1 = read.table(file = "/Users/wanxinli/Desktop/project.nosync/MLDSP-desktop/samples/ERP108418_metadata.csv", sep = ",", header = TRUE)
# tab1 = read.table(file = "samples/rumen_mag_metadata.csv", sep = "\t", header = TRUE)


library(ggplot2)

#ALL DATA

#GC content histogram
png("paper_plots/ERP108418_GC.png", width = 324.18, height = 400)
qplot(tab1$gc_percentage, geom="histogram", ylab = "Number of genomes (all)", xlab = "Percent GC")
dev.off()

#contig count, outliers above 1000 removed
png("paper_plots/ERP108418_contig.png", width = 324.18, height = 400)
# qplot(tab1[which(tab1$contig_count<1000),"contig_count"], geom = "histogram", ylab = "Number of genomes (all)", xlab = "Contig count (max 1000 displayed)")
qplot(tab1$contig_count, geom = "histogram", ylab = "Number of genomes (all)", xlab = "Contig count")
dev.off()

#genome size
png("paper_plots/ERP108418_genome.png", width = 324.18, height = 400)
# qplot(tab1[which(tab1$genome_size<12500000),'genome_size'], geom = "histogram", ylab = "Number of genomes (all)", xlab = "Genome size in basepairs (max 1.25 Gbp displayed)")
qplot(tab1$genome_size, geom = "histogram", ylab = "Number of genomes (all)", xlab = "Genome size in basepairs")
dev.off()

# #REPRESENTATIVES

# tab2 = tab1[which(tab1$gtdb_representative=="t"),]

# #GC content histogram
# qplot(tab2$gc_percentage, geom="histogram", ylab = "Number of genomes (species-level representatives)", xlab = "Percent GC")

# #contig count, outliers above 1000 removed
# qplot(tab2[which(tab2$contig_count<1000),2], geom = "histogram", , ylab = "Number of genomes (species-level representatives)", xlab = "Contig count (max 1000 displayed)")

# #genome size
# qplot(tab2[which(tab2$genome_size<12500000),5], geom = "histogram", ylab = "Number of genomes (species-level representatives)", xlab = "Genome size in basepairs (max 1.25 Gbp displayed)")
