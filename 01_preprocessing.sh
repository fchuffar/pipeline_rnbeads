cd ~/projects/lfs_patients_fibroblast/results/epic_lfs_diagenode
source config
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/

# organize idat
mkdir -p ~/projects/${datashare}/${gse}/idat
cd ~/projects/${datashare}/${gse}/idat
ls -lha ~/projects/datashare_epistorage/epic_lfs_diagenode/raw/raw_data/205045*/*.idat | wc
ln -s ~/projects/datashare_epistorage/epic_lfs_diagenode/raw/raw_data/2050*/*.idat .
ls -lha

rsync -auvP --exclude="raw_data" cargo:~/projects/datashare_epistorage/epic_lfs_diagenode/ ~/projects/datashare_epistorage/epic_lfs_diagenode/


# retrieve fastq
ssh cargo
mkdir -p ~/projects/${datashare}/${gse}/raw
cd ~/projects/${datashare}/${gse}/raw
for srr in SRR3467835 SRR3467836 SRR3467837 SRR3467838 SRR3467839 SRR3467840 SRR3467841 SRR3467842 SRR3467843 
do
  echo ${srr}
  prefetch $srr
  vdb-validate $srr
  parallel-fastq-dump --threads 16 --tmpdir /dev/shm --gzip --split-files --outdir ./ --sra-id ${srr}
done
exit 

# launch bismark
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/
ssh dahu
snakemake -s ~/projects/${project}/results/${gse}/wf_rrbs.py --cores 50 --cluster "oarsub --project epimed -l nodes=1/core={threads},walltime=6:00:00 " --latency-wait 60 -pn
ssh cargo ls projects/${datashare}/${gse}
mkdir -p ~/projects/${datashare}/${gse}/
rsync -auvP cargo:projects/${datashare}/${gse}/multiqc_rrbs* ~/projects/${datashare}/${gse}/.
rsync -auvP cargo:projects/${datashare}/${gse}/*sorted.bam* ~/projects/${datashare}/${gse}/.
rsync -auvP cargo:projects/${datashare}/${gse}/*bismark.cov.gz ~/projects/${datashare}/${gse}/.
open ~/projects/${datashare}/${gse}/multiqc_rrbs.html

# launch RnBeads
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 02_rnbeads_go.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
echo ${project}/results/${gse}/rnbead_results
mkdir -p ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/${version}/ 
rsync -auvP cargo:~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/${version}/*.bigWig ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/${version}/.

# run ewas
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
rsync -auvP cargo:projects/${project}/results/${gse}/ewas_results/ ~/projects/${project}/results/${gse}/ewas_results/

# run combp
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
rsync -auvP cargo:projects/${project}/results/${gse}/combp_results/*.regions-p.bed.gz ~/projects/${project}/results/${gse}/combp_results/




/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -jar /Applications/IGV_2.4.16.app/Contents/Java/igv.jar \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_01.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_02.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_03.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_04.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_05.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_06.bigWig \
  /Users/florent/projects/${datashare}/${gse}/SRR3467835_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR3467836_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR3467837_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR3467839_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR3467840_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR3467841_1_trimmed_bismark_bt2_sorted.bam \





