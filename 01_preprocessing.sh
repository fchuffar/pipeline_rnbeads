cd ~/projects/javed/results/rrbs_javed_integragen
source config
echo ${gse}
echo ${project}
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/


# for idat from NCBI/GEO, go to 02_rnbeads_gseidat2study

# organize idat
mkdir -p ~/projects/datashare/${gse}/raw
cd ~/projects/datashare/${gse}/raw
ls -lha ~/projects/datashare_epistorage/epic_lfs_diagenode/raw/raw_data/205045*/*.idat | wc
ln -s ~/projects/datashare_epistorage/epic_lfs_diagenode/raw/raw_data/2050*/*.idat .
ls -lha

rsync -auvP --exclude="raw_data" cargo:~/projects/datashare_epistorage/epic_lfs_diagenode/ ~/projects/datashare_epistorage/epic_lfs_diagenode/





# retrieve and organize RRBS fastq files
rsync -auvP ~/projects/datashare/${gse}/raw/ cargo:~/projects/datashare/${gse}/raw/
ssh cargo
mkdir -p ~/projects/datashare/${gse}/raw
cd ~/projects/datashare/${gse}/raw

for srr in SRR3467835 SRR3467836 SRR3467837 SRR3467838 SRR3467839 SRR3467840 SRR3467841 SRR3467842 SRR3467843 
do
  echo ${srr}
  prefetch $srr
  vdb-validate $srr
  parallel-fastq-dump --threads 16 --tmpdir /dev/shm --gzip --split-files --outdir ./ --sra-id ${srr}
done
exit 

cd ~/projects/datashare/${gse}/raw
md5sum *.fastq.gz > md5sum.bettik.txt 
diff md5sum.bettik.txt md5sum.mgx.txt 
rsync -auvP ~/projects/datashare/${gse}/ ~/projects/datashare_epistorage/${gse}/
cd ~/projects/datashare_epistorage/${gse}/raw
md5sum *.fastq.gz > md5sum.summer.txt 
diff md5sum.bettik.txt md5sum.mgx.txt 


source ~/conda_config.sh
conda activate rrbs_env 
# launch bismark
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/
ssh dahu
snakemake -s ~/projects/${project}/results/${gse}/wf_rrbs.py --jobs 50 --cluster "oarsub --project epimed -l nodes=1/core={threads},walltime=6:00:00 " --latency-wait 60 -pn
ssh cargo ls projects/datashare/${gse}
mkdir -p ~/projects/datashare/${gse}/
rsync -auvP cargo:projects/datashare/${gse}/multiqc_rrbs* ~/projects/datashare/${gse}/.
rsync -auvP cargo:projects/datashare/${gse}/*sorted.bam* ~/projects/datashare/${gse}/.
rsync -auvP cargo:projects/datashare/${gse}/*bismark.cov.gz ~/projects/datashare/${gse}/.
open ~/projects/datashare/${gse}/multiqc_rrbs.html

# export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
# cd /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/
# bismark --multicore `echo "$((16 / 2))"` -n 1 ~/projects/datashare/genomes/Rattus_norvegicus/UCSC/rn6/Sequence/WholeGenomeFasta/   -1 /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1.fq.gz     -2 /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R2_001_val_2.fq.gz
# samtools sort -@ 16 -T /dev/shm/F3C7_S19 -o /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe_sorted.bam /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe.bam
# # rm /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe.bam
# samtools index /home/fchuffar/projects/datashare/rrbs_symer_mgx/raw/F3C7_S19_R1_001_val_1_bismark_bt2_pe_sorted.bam

# set design using design_rrbs.sh
source ~/conda_config.sh
# conda create -n rnbeadsrrbs_env
conda activate rnbeadsrrbs_env
# mamba install -c anaconda -c bioconda -c conda-forge -c r r-base libopenblas bioconductor-geoquery bioconductor-affy bioconductor-biobase r-seqinr r-rcpparmadillo r-devtools r-fastmap r-matrix r-kernsmooth r-catools r-gtools r-nortest r-survival r-beanplot r-gplots bioconductor-rnbeads r-doparallel bioconductor-rnbeads.hg19 ghostscript bioconductor-watermelon bioconductor-illuminahumanmethylation450kanno.ilmn12.hg19 bioconductor-illuminahumanmethylationepicanno.ilm10b4.hg19 bioconductor-illuminahumanmethylation27kanno.ilmn12.hg19 snakemake=7.32.4 bioconductor-gostats r-hexbin r-wordcloud bioconductor-lola r-simplecache bioconductor-qvalue
# devtools::install_github("fchuffar/epimedtools")
# launch RnBeads
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 02_rnbeads_go.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
echo ${project}/results/${gse}/rnbead_vignettes
mkdir -p ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/${version}/ 
rsync -auvP cargo:~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/${version}/*.bigWig ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/${version}/.

# run ewas
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
rsync -auvP cargo:projects/${project}/results/${gse}/ewas_vignettes/ ~/projects/${project}/results/${gse}/ewas_vignettes/

# run combp
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
rsync -auvP cargo:projects/${project}/results/${gse}/combp_vignettes/*.regions-p.bed.gz ~/projects/${project}/results/${gse}/combp_vignettes/




/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -jar /Applications/IGV_2.4.16.app/Contents/Java/igv.jar \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_01.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_02.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_03.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_04.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_05.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_vignettes/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_06.bigWig \
  /Users/florent/projects/datashare/${gse}/SRR3467835_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467836_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467837_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467839_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467840_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/datashare/${gse}/SRR3467841_1_trimmed_bismark_bt2_sorted.bam \





