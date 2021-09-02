source("config")
library(RnBeads)
# library(RnBeads.mm10)







# Directory where your data is located
data.dir = file.path(paste0("~/projects/", datashare, "/", gse, "/"), "idat")
sample.sheet = file.path(paste0("~/projects/", datashare, "/", gse, "/"), "sample_annotation.csv")
# Directory where the output should be written to
analysis.dir = paste0("~/projects/", project, "/results/", gse, "/analysis")
# Directory where the report files should be written to
dir.reports = file.path(analysis.dir, "reports")
data.type="infinium.idat.dir"



RnBeads::rnb.options(
  analysis.name        = gse,
  email = "florent.chuffart@univ-grenoble-alpes.fr",

  filtering.sex.chromosomes.removal=TRUE, 
  identifiers.column="Sample_ID",
  export.to.csv=TRUE,
  # import.idat.platform = "probesEPIC",
  # replicate.id.column = "treatment",
  # import.table.separator = ";",
  # import.bed.style     = "bismarkCov",
  # assembly             = version,
  region.types=c("promoters","genes","tiling","cpgislands","sites"),
  # region.aggregation="coverage.weighted",
  gz.large.files=TRUE,
  # differential.enrichment.go = TRUE
  # differential.enrichment.lola = TRUE,
  exploratory=FALSE,
  differential=FALSE
)








dir.create(dir.reports, showWarnings=FALSE)
num.cores = 32
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



# RnBeads::rnb.run.analysis(dir.reports=dir.reports, sample.sheet=sample.sheet, data.dir=data.dir, data.type="infinium.idat.dir")

stop("EFN")



# Directory where your data is located
data.dir = paste0("~/projects/", project, "/results/", gse, "/Ziller2011_PLoSGen_450K")
idat.dir = file.path(data.dir, "idat")
sample.sheet = file.path(data.dir, "sample_annotation.csv")
# Directory where the output should be written to
analysis.dir = paste0("~/projects/", project, "/results/", gse, "/analysis")
# Directory where the report files should be written to
dir.reports = file.path(analysis.dir, "reports")



RnBeads::rnb.options(
  filtering.sex.chromosomes.removal=TRUE,
  identifiers.column="Sample_ID",
  export.to.csv=TRUE,
  exploratory=FALSE,
  differential=FALSE
)



dir.create(dir.reports, showWarnings=FALSE)
num.cores = 32
parallel.setup(num.cores)

unlink(dir.reports, recursive=TRUE)
RnBeads::rnb.run.analysis(dir.reports=dir.reports, sample.sheet=sample.sheet, data.dir=idat.dir, save.rdata = TRUE, data.type="infinium.idat.dir")






















data.source = NULL
# sample.sheet = NULL
# data.dir = NULL
GS.report = NULL
GEO.acc = NULL
# data.type = rnb.getOption("import.default.data.type")
initialize.reports = TRUE
build.index = TRUE
save.rdata = FALSE

dir.reports=dir.reports
sample.sheet=sample.sheet
data.dir=idat.dir
data.type="infinium.idat.dir"



unlink(dir.reports, recursive=TRUE)

# function (dir.reports, data.source = NULL, sample.sheet = NULL,
#     data.dir = NULL, GS.report = NULL, GEO.acc = NULL, data.type = rnb.getOption("import.default.data.type"),
#     initialize.reports = TRUE, build.index = TRUE, save.rdata = TRUE)
# {
    if (all(is.null(c(sample.sheet, data.dir, GS.report, GEO.acc, 
        data.source)))) {
        stop("one of the sample.sheet, data.dir, GS.report, GEO.acc, data.source should be specified")
    }
    if (is.null(data.source)) {
        if (!is.null(GS.report)) {
            data.type <- "GS.report"
            data.source <- GS.report
        }
        else if (!is.null(GEO.acc)) {
            data.type <- "GEO"
            data.source <- GEO.acc
        }
        else if (!is.null(sample.sheet) & !is.null(data.dir)) {
            data.source <- list(data.dir = data.dir, sample.sheet = sample.sheet)
        }
        else if (!is.null(sample.sheet) & is.null(data.dir)) {
            stop("data directory is missing")
        }
        else if (is.null(sample.sheet) & !is.null(data.dir)) {
            stop("sample sheet is missing")
        }
    }
    if (!(is.character(dir.reports) && length(dir.reports) == 
        1 && (!is.na(dir.reports)))) {
        stop("invalid value for dir.reports; expected one-element character")
    }
    # if (!parameter.is.flag(initialize.reports)) {
    #     stop("invalid value for initialize.reports; expected TRUE or FALSE")
    # }
    # if (!parameter.is.flag(build.index)) {
    #     stop("invalid value for build.index; expected TRUE or FALSE")
    # }
    if (initialize.reports) {
        if (!rnb.initialize.reports(dir.reports)) {
            stop(paste("Could not initialize reports in", dir.reports, 
                "; make sure this path does not exist."))
        }
    } else if (!isTRUE(file.info(dir.reports)[1, "isdir"])) {
        stop("invalid value for dir.reports; expected existing directory")
    }
    if (logger.isinitialized()) {
        logfile <- NULL
        log.file <- NULL
    }    else {
        log.file <- "analysis.log"
        logfile <- c(file.path(dir.reports, log.file), NA)
    }
    logger.start("RnBeads Pipeline", fname = logfile)
    aname <- rnb.getOption("analysis.name")
    if (!(is.null(aname) || is.na(aname) || nchar(aname) == 0)) {
        logger.info(c("Analysis Title:", aname))
    }
    rm(aname)
    update.index <- function(dset, rname = "", skip.normalization = FALSE) {
        if (build.index) {
            if (is.null(dset)) {
                export.enabled <- TRUE
            }
            else {
                export.enabled <- rnb.getOption("export.to.csv") || 
                  rnb.tracks.to.export(dset)
            }
            RnBeads:::rnb.build.index.internal(dir.reports, log.file = log.file, 
                export.enabled = export.enabled, current.report = rname, 
                open.index = (rname == ""))
        }
    }
    cat(rnb.options2xml(), file = file.path(dir.reports, "analysis_options.xml"))
    if (rnb.getOption("import")) {
        if (is.character(data.source) || is.list(data.source) || 
            inherits(data.source, "RnBSet")) {
              print("bla****************************************")
            update.index(NULL, "data_import", data.type == "bed.dir")
            result <- rnb.run.import(data.source, data.type, 
                dir.reports)
            rnb.set <- result$rnb.set
            rm(result)
            RnBeads:::rnb.cleanMem()
        }        else {
            stop("invalid value for data.source")
        }
    }     else if (inherits(data.source, "RnBSet")) {
        rnb.set <- data.source
    }    else if (inherits(data.source, "MethyLumiSet")) {
        rnb.set <- as(data.source, "RnBeadSet")
    }    else {
        logger.warning("Cannot proceed with the supplied data.source. Check the option import")
        logger.completed()
        if (!is.null(logfile)) {
            logger.close()
        }
        return(invisible(NULL))
    }


    if (save.rdata) {
        analysis.options <- rnb.options()
        save.rnb.set(rnb.set, file.path(dir.reports, "rnbSet_unnormalized"), 
            archive = rnb.getOption("gz.large.files"))
        save(analysis.options, file = file.path(dir.reports, 
            "analysis_options.RData"))
    }
    if (rnb.getOption("qc")) {
        update.index(rnb.set, "quality_control")
        RnBeadSet:::rnb.cleanMem()
        rnb.run.qc(rnb.set, dir.reports)
    }
    if (rnb.getOption("preprocessing")) {
        update.index(rnb.set, "preprocessing")
        RnBeadSet:::rnb.cleanMem()
        result <- rnb.run.preprocessing(rnb.set, dir.reports)
        rnb.set <- result$rnb.set
        rm(result)
        RnBeadSet:::rnb.cleanMem()
        if (save.rdata) {
            save.rnb.set(rnb.set, file.path(dir.reports, "rnbSet_preprocessed"), 
                archive = rnb.getOption("gz.large.files"))
        }
    }
    sample.count <- nrow(pheno(rnb.set))
    if (nsites(rnb.set) * sample.count != 0) {
        if (rnb.getOption("export.to.csv") || rnb.tracks.to.export(rnb.set)) {
            update.index(rnb.set, "tracks_and_tables")
            RnBeadSet:::rnb.cleanMem()
            rnb.run.tnt(rnb.set, dir.reports)
        }
        if (rnb.getOption("inference")) {
            update.index(rnb.set, "covariate_inference")
            rnb.set <- rnb.run.inference(rnb.set, dir.reports)$rnb.set
            if (save.rdata) {
                save.rnb.set(rnb.set, file.path(dir.reports, 
                  "rnbSet_inference"), archive = rnb.getOption("gz.large.files"))
            }
        }
        if (rnb.getOption("exploratory")) {
            update.index(rnb.set, "exploratory_analysis")
            RnBeadSet:::rnb.cleanMem()
            rnb.run.exploratory(rnb.set, dir.reports)
        }
        if (rnb.getOption("differential")) {
            update.index(rnb.set, "differential_methylation")
            RnBeadSet:::rnb.cleanMem()
            result.diffmeth <- rnb.run.differential(rnb.set, 
                dir.reports)
        }
    }
    update.index(rnb.set)
    if (save.rdata) {
        RnBeadSet:::rnb.cleanMem()
        logger.start("Saving RData")
        if (exists("result.diffmeth")) {
            if (!is.null(result.diffmeth) && !is.null(result.diffmeth$diffmeth)) {
                diffmeth.path <- file.path(dir.reports, "differential_rnbDiffMeth")
                save.rnb.diffmeth(result.diffmeth$diffmeth, diffmeth.path)
                diffmeth.go.enrichment <- result.diffmeth$dm.go.enrich
                if (!is.null(diffmeth.go.enrichment)) {
                  save(diffmeth.go.enrichment, file = file.path(diffmeth.path, 
                    "enrichment_go.RData"))
                }
                diffmeth.lola.enrichment <- result.diffmeth$dm.lola.enrich
                if (!is.null(diffmeth.lola.enrichment)) {
                  save(diffmeth.lola.enrichment, file = file.path(diffmeth.path, 
                    "enrichment_lola.RData"))
                }
            }
            else {
                logger.warning("Differential methylation object not saved")
            }
        }
        logger.completed()
    }
    RnBeadSet:::rnb.cleanMem()
    logger.completed()
    if (!is.null(logfile)) {
        logger.close()
    }
    invisible(rnb.set)
# }







sessionInfo()






