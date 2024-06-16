source("config")
library(RnBeads)
# library(RnBeads.mm10)
library(paste0("RnBeads.", version), character.only=TRUE)


analysis.name = gse
data.dir = paste0("~/projects/", datashare, "/", analysis.name, "/")
sample.sheet = "sample.txt"
data.source = list(data.dir = data.dir, sample.sheet = sample.sheet)
data.type = "bed.dir"
dir.reports = "rnbead_results"

RnBeads::rnb.options(
  analysis.name        = analysis.name,
  email = "florent.chuffart@univ-grenoble-alpes.fr",
  identifiers.column   = "sampleID",
  replicate.id.column = "treatment",
  import.table.separator = ";",
  import.bed.style     = "bismarkCov",
  assembly             = version,
  filtering.sex.chromosomes.removal=TRUE,
  region.types=c("promoters","genes","tiling","cpgislands","sites"),
  region.aggregation="coverage.weighted",
  gz.large.files=TRUE,
  differential.enrichment.go = TRUE
  # differential.enrichment.lola = TRUE,
) # Options de l'analyse
num.cores = 32
parallel.setup(num.cores)


unlink(dir.reports, recursive=TRUE)
rnb.run.analysis(
  dir.reports = dir.reports,
  data.source = data.source,
  data.type = data.type,
  initialize.reports=TRUE
) 

sessionInfo()






