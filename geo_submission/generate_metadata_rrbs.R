source("../config")

samples = read.table(paste0("/bettik/chuffarf/geo_submission/", project, "/", gse, "/bw_beta/md5.geo.txt"))
head(samples)
dim(samples)



samples$sample_name            = do.call(rbind, strsplit(samples[,2], "\\.|_R1"))[,2]
rownames(samples) = samples$sample_name
samples$title                  = samples$sample_name
samples$organism               = species
# samples$tissue                 = tissue
samples$cell_line              = do.call(rbind, strsplit(samples$sample_name, "-"))[,1]
# samples$cell_type              = cell_type
# samples$genotype               = dict_genotype  [genotype    [rownames(samples)]]
samples$treatment              = substr(samples$sample_name, nchar(samples$cell_line)+2, 1000)
# samples$transfection           = transfection[rownames(samples)]
# samples$vector                 = vector      [rownames(samples)]
# samples$batch_id               = batch_id    [rownames(samples)]
# samples$culture                = culture     [rownames(samples)]
# samples$molecule               = "RNA-seq"
samples$single_or_paired_end   = "paired-end"
samples$instrument_model       = "Illumina Novaseq X plus"
samples$processed_data_file1   = paste0("", samples$sample_name, "_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.bw")
samples$processed_data_file2   = paste0("", samples$sample_name, "_R1_val_1_bismark_bt2_pe_sorted_4_RPKM.bw")
samples$raw_file1              = paste0(samples$sample_name, "_R1.fastq.gz")
samples$raw_file2              = paste0(samples$sample_name, "_R2.fastq.gz")
head(samples)

samples = samples[,-(1:2)] 
samples
head(samples)
dim(samples)
WriteXLS::WriteXLS(samples, "01_samples.xlsx")







proc_data_files = read.table(paste0("/bettik/chuffarf/geo_submission/", project, "/", gse, "/bw_beta/md5.geo.txt"))
head(proc_data_files)
dim(proc_data_files)

proc_data_files$filename = proc_data_files[,2]
proc_data_files$checksum = proc_data_files[,1]
proc_data_files$filetype = "bw_beta"

proc_data_files = proc_data_files[,-(1:2)]
proc_data_files
WriteXLS::WriteXLS(proc_data_files, "02_bw_beta_files.xlsx")


proc_data_files = read.table(paste0("/bettik/chuffarf/geo_submission/", project, "/", gse, "/bw_cov/md5.geo.txt"))
head(proc_data_files)
dim(proc_data_files)

proc_data_files$filename = proc_data_files[,2]
proc_data_files$checksum = proc_data_files[,1]
proc_data_files$filetype = "bw_cov"

proc_data_files = proc_data_files[,-(1:2)]
proc_data_files
WriteXLS::WriteXLS(proc_data_files, "02_bw_cov_files.xlsx")








raw_files = read.table(paste0("/bettik/chuffarf/geo_submission/", project, "/", gse, "/fastq/md5.geo.txt"))
head(raw_files)
dim(raw_files)

raw_files$filename =         raw_files[,2]
raw_files$checksum =         raw_files[,1]
raw_files$filetype =         "fastq"

raw_files = raw_files[,-(1:2)] 
raw_files
WriteXLS::WriteXLS(raw_files, "03_raw_files.xlsx")













paired_end_experiments = data.frame(filename1=samples$raw_file1, filename2=samples$raw_file2)
head(paired_end_experiments)
dim(paired_end_experiments)
WriteXLS::WriteXLS(paired_end_experiments, "04_paired_end_experiments.xlsx")






