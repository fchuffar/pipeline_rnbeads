source("config")
source("config.R")
dir.create(path="combp_results", showWarnings=FALSE)
for (cov_thresh in cov_threshs) {
  ewas_filename = paste0("ewas_results/ewas_covthresh", cov_thresh, ".rds")
  print(ewas_filename)
  ewas = t(readRDS(ewas_filename))

  # layout(matrix(1:6, 2), respect=TRUE)
  # plot(ewas[1,], -log10(ewas[2,]))
  # plot(-log10(ewas[2,]), -log10(ewas[3,]), col=(ewas[2,]<0.05 | ewas[3,]<0.05)+1)
  # idx6 = colnames(ewas)[ewas[2,]<0.05 | ewas[3,]<0.05]
  # print(paste0("#CpG of interest:" , length(idx6)))

  tests = paste0(substr(colnames(ewas)[1:3], 6,6), "test")
  for (test in tests) {
    suffix = paste0(test,"_covthresh", cov_thresh)
    if (!file.exists(paste0("combp_results/dmrbycombp1000_", suffix, ".regions.bed.gz"))) {
      res_EWAS = ewas[,c(4,which(test==tests))]
      head(res_EWAS)
      tmp_split = strsplit(rownames(res_EWAS),"_")
      tmp_split = do.call(rbind, tmp_split)
      head(tmp_split)
      methpf = data.frame(id=rownames(res_EWAS), chr=tmp_split[,1] ,pos=as.numeric(tmp_split[,2]) ,stringsAsFactors=FALSE)
      rownames(methpf) = methpf$id
      methpf = methpf[,-1]
      bedfile = methpf
      colnames(bedfile) = c("chrom","start")
      bedfile$end = bedfile$start + 1
      head(bedfile)

      ewasforcombp2 = merge(bedfile,res_EWAS, by=0)
      ewasforcombp2 = as.data.frame(ewasforcombp2)
      rownames(ewasforcombp2) = ewasforcombp2[,1]
      ewasforcombp2 = ewasforcombp2[,-1]
      ewasforcombp2 = ewasforcombp2[order(ewasforcombp2$chrom, ewasforcombp2$start),]
      head(ewasforcombp2)
      dim(ewasforcombp2)

      print("writing ewasforcombp...")
      head(ewasforcombp2)
      write.table(ewasforcombp2, file=paste0("combp_results/ewasforcombp_",suffix,".bed"), sep="\t", quote=FALSE,row.names=FALSE, col.names=TRUE)
      print("done.")

      # quantile(ewasforcombp2[,5])

      print("launching comb-p...")
      cmd ="/summer/epistorage/miniconda3/bin/python"
      arg = paste0("/summer/epistorage/opt/combined-pvalues/cpv/comb-p pipeline --no-fdr -c 5 --seed 0.0001 --dist 1000 -p combp_results/dmrbycombp1000_",suffix," --region-filter-p 0.05 --region-filter-n 2 combp_results/ewasforcombp_",suffix,".bed")
      print(paste(cmd, arg))
      system2(cmd, arg)
      print("done.")
    } else {
      print(paste0("combp ncalled for suffix ", suffix))
    }
  }
}



pdf("combp_results/pval_dist.pdf")
# layout(matrix(1:(3*length(cov_threshs)),3), respect=TRUE)
for (cov_thresh in cov_threshs) {
  for (test in tests) {
    regionp_file = paste0("combp_results/dmrbycombp1000_", test, "_covthresh", cov_thresh, ".regions-p.bed.gz")
    if (file.exists(regionp_file)) {
      foo = read.table(gzfile(regionp_file), comment="@", header=TRUE)
      foo$len = foo[,3] - foo[2]
      print(head(foo [order(foo$z_sidak_p),]))
      pv = foo[,"z_sidak_p"]
      if (length(pv)>1) {
        plot(density(-log10(pv)), main=paste(cov_thresh, test))
      } else {
        plot(1, -log10(pv), main=paste(cov_thresh, test))
      }
    } else {
      plot(0,0, main=paste(cov_thresh, test))
    }
  }
}
dev.off()



stop("EFN")


sessionInfo()





