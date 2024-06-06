source("../config")

samples = read.table(paste0("/bettik/chuffarf/geo_submission/", project, "/", gse, "/idat/md5.geo.txt"))
samples = samples[((1:(nrow(samples)/2))*2)-1,]
head(samples)
dim(samples)


df = openxlsx::read.xlsx("PJ2007233-Suivi-Labo.xlsx")  
df = df[!is.na(df$Sentrix.Barcode),]
rownames(df) = paste0(df$Sentrix.Barcode, "_", df$Sample.Section)

samples$sample_name            = substr(samples[,2], 1, 19)
rownames(samples) = samples$sample_name
samples$title                  = samples$sample_name
samples$organism               = species 
samples$sample_id              = substr(df[rownames(samples),]$Sample.ID, 1, 10)
samples$sample_id_orig         = df[rownames(samples),]$Sample.ID
samples$Sentrix.Barcode        = df[rownames(samples),]$Sentrix.Barcode
samples$Sample.Section         = df[rownames(samples),]$Sample.Section
# samples$tissue                 = tissue
# samples$cell_line              = ""
# samples$cell_type              = cell_type
# samples$genotype               = dict_genotype  [genotype    [rownames(samples)]]
# samples$treatment              = dict_medium    [medium      [rownames(samples)]]
# samples$transfection           = transfection[rownames(samples)]
# samples$vector                 = vector      [rownames(samples)]
# samples$batch_id               = batch_id    [rownames(samples)]
# samples$culture                = culture     [rownames(samples)]
# samples$molecule               = "RNA-seq"
# samples$single_or_paired_end   = single_or_paired_end
# samples$instrument_model       = instrument_model
# samples$processed_data_file    = samples[,2]
samples$raw_file1              = paste0(substr(samples[,2], 1, 19), "_Grn.idat")
samples$raw_file2              = paste0(substr(samples[,2], 1, 19), "_Red.idat")
head(samples)

samples = samples[,-(1:2)] 
samples
head(samples)
dim(samples)
WriteXLS::WriteXLS(samples, "01_samples.xlsx")







# proc_data_files = read.table(paste0("/bettik/chuffarf/geo_submission/", gse, "/counts/md5.geo.txt"))
# head(proc_data_files)
# dim(proc_data_files)
#
# proc_data_files$filename = proc_data_files[,2]
# proc_data_files$checksum = proc_data_files[,1]
# proc_data_files$filetype = "counts"
#
# proc_data_files = proc_data_files[,-(1:2)]
# proc_data_files
# WriteXLS::WriteXLS(proc_data_files, "02_proc_data_files.xlsx")








raw_files = read.table(paste0("/bettik/chuffarf/geo_submission/", project, "/", gse, "/idat/md5.geo.txt"))
head(raw_files)
dim(raw_files)

raw_files$filename =         raw_files[,2]
raw_files$checksum =         raw_files[,1]
raw_files$filetype =         "idat"

raw_files = raw_files[,-(1:2)] 
raw_files
WriteXLS::WriteXLS(raw_files, "03_raw_files.xlsx")













paired_end_experiments = data.frame(filename1=samples$raw_file1, filename2=samples$raw_file1)
head(paired_end_experiments)
WriteXLS::WriteXLS(paired_end_experiments, "04_paired_end_experiments.xlsx")







# The sequenced reads from the raw sequence (.idat files) were aligned on the UCSC mm10 genome using the STAR software (2.7.1a) (Dobin et al. 2013) [PMID:23104886] to produce bam files.
# The aligned reads (.bam files) were counted using HTSeq framework (0.11.2) (Anders et al. 2015) [PMID:25260700], with options: -t exon -f bam -r pos –stranded=reverse -m intersection-strict –nonunique none.


# samples$cond           = cond[rownames(samples)]
# table(samples$batch_id, samples$cond))]
#   #
#   #         cond1 cond2 cond3 cond4 cond5 cond6 cond7 cond8
#   # b0103n1     0     0     0     0     0     1     1     1
#   # b0205n2     0     0     1     1     1     0     0     0
#   # b0303n1     0     0     0     0     0     1     1     1
#   # b0305n1     0     0     1     1     1     0     0     0
#   # b0305n2     0     0     1     1     1     0     0     0
#   # b1301n1     1     1     0     0     0     0     0     0
#   # b1401n1     1     1     0     0     0     0     0     0
#   # b1612n1     1     1     0     0     0     0     0     0
#   # b1712n1     1     1     0     0     0     0     0     0
#   # b2203n1     0     0     1     1     1     0     0     0
#   # b2402n1     0     0     0     0     0     1     1     1
#   # b2904n1     0     0     0     0     0     1     1     1
# cond1 vs. cond2
# cond3 vs. cond4 vs. cond5
# cond6 vs. cond6 vs. cond7
