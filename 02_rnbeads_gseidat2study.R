source("config")
wd_orig = getwd()
epimedtools::download_gse_raw_tar(gse)

library(RnBeads)
library(grid)

# Directory where iDAT are stored
data.dir = paste0("~/projects/", datashare, "/", gse, "/raw")

# unzip idat.gz files
setwd(data.dir)
cmd = "gzip"
args = ("-d *.idat.gz")
print(paste(cmd, args))
system2(cmd, args)
setwd(wd_orig)


# Design
idat_red_files = list.files(data.dir, "*_Red.idat")
idat_red_files = idat_red_files[substr(idat_red_files, 1, 3)=="GSM"]
exp_grp = do.call(rbind, strsplit(idat_red_files, "_"))[,1:3]
colnames(exp_grp) = c("Sample_ID", "Sentrix_ID", "Sentrix_Position")
rownames(exp_grp) = exp_grp[,1]
exp_grp = as.data.frame(exp_grp)
# exp_grp = exp_grp[1:2,]
head(exp_grp)
dim(exp_grp)
write.table(exp_grp, "exp_grp.csv", sep=",", row.names=FALSE, quote=FALSE)
sample.sheet = "exp_grp.csv"

# format idat file using symblink
setwd(data.dir)
foo = apply(exp_grp, 1, function (row) {
  cmd = "ln"
  args = paste0("-s ", row[[1]], "_", row[[2]], "_", row[[3]], "_Red.idat ", row[[2]], "_", row[[3]], "_Red.idat")
  print(paste(cmd, args))
  system2(cmd, args)
  args = paste0("-s ", row[[1]], "_", row[[2]], "_", row[[3]], "_Grn.idat ", row[[2]], "_", row[[3]], "_Grn.idat")
  print(paste(cmd, args))
  system2(cmd, args)
})
setwd(wd_orig)

# Directory where the output should be written to
analysis.dir = paste0("~/projects/", project, "/vignettes/", gse, "/analysis")

# Directory where the report files should be written to
dir.reports = file.path(analysis.dir, "reports")
data.type="infinium.idat.dir"

# Options, https://rdrr.io/bioc/RnBeads/man/rnb.options.html
RnBeads::rnb.options(
  analysis.name        = gse,
  email = "florent.chuffart@univ-grenoble-alpes.fr",
  filtering.sex.chromosomes.removal=FALSE, 
  identifiers.column="Sample_ID",
  export.to.csv=TRUE,
  # import.idat.platform = "probesEPIC",
  # replicate.id.column = "treatment",
  # import.table.separator = ";",
  # import.bed.style     = "bismarkCov",
  # assembly             = version,
  # region.types=c("promoters", "genes", "tiling", "cpgislands", "sites"),
  region.types=c("sites"),
  # region.aggregation="coverage.weighted",
  gz.large.files=TRUE,
  # differential.enrichment.go = TRUE
  # differential.enrichment.lola = TRUE,


  # export.to.csv        = "yes",
  export.to.bed        = FALSE,
  export.to.trackhub   = NULL,
  # export.to.ewasher    = "no",


  exploratory=FALSE,
  differential=FALSE
)
# foo = RnBeads::rnb.options()
# foo$export.to.trackhub







dir.create(dir.reports, showWarnings=FALSE)
num.cores = 24
parallel.setup(num.cores)

unlink(dir.reports, recursive=TRUE)
RnBeads::rnb.run.analysis(
  dir.reports=dir.reports, 
  sample.sheet=sample.sheet, 
  data.dir=data.dir, 
  data.type=data.type,
  # data.source = data.source,
  # GS.report = NULL,
  # GEO.acc = NULL,
  # build.index = TRUE,
  save.rdata = FALSE,
  initialize.reports=TRUE
)


beta_matrixcsv_file = paste0("~/projects/dnamaging/vignettes/", gse, "/analysis/reports/tracks_and_tables_data/csv/betas_1.csv.gz")
print(beta_matrixcsv_file)
df = read.table(beta_matrixcsv_file, sep=",", row.names=1, header=TRUE)
head(df[,1:10])
dim(df)

pf = df[,1:4]
head(pf)
dim(pf)

data = as.matrix(df[,-(1:4)])
head(data[,1:6])
dim(data)

head(exp_grp)
dim(exp_grp)




s = epimedtools::create_study()
s$data     = data
s$exp_grp  = exp_grp
s$platform = pf
s_filename = paste0("~/projects/datashare/", gse, "/study_", gse, "_idat_rnbeads.rds")
print(paste0("Writing ", s_filename, "..."))
s$save(s_filename)

  
