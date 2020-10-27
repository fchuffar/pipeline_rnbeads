cd ~/projects/temporise/results/GSE80959
source config
pwd
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/

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

# run ewas
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 03_ewas.R";
oarstat -fj ${OAR_JOB_ID}
tail -f OAR.${OAR_JOB_ID}.stdout 
rsync -auvP cargo:projects/${project}/results/${gse}/ewas_results/ ~/projects/${project}/results/${gse}/ewas_results/

# get bam files
ssh cargo ls ~/projects/${datashare}/${gse}
mkdir -p ~/projects/${datashare}/${gse}/
rsync -auvP cargo:projects/${datashare}/${gse}/*sorted.bam* ~/projects/${datashare}/${gse}/








mkdir -p ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/ 
rsync -auvP cargo:~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/*.bigWig ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/.

/Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Home/bin/java -jar /Applications/IGV_2.4.16.app/Contents/Java/igv.jar \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_01.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_02.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_03.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_04.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_05.bigWig \
  ~/projects/${project}/results/${gse}/rnbead_results/tracks_and_tables_data/sites/trackHub_bigWig/mm10/rnbeads_sample_06.bigWig \
  /Users/florent/projects/${datashare}/${gse}/SRR9016929_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR9016930_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR9016931_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR9016934_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR9016935_1_trimmed_bismark_bt2_sorted.bam \
  /Users/florent/projects/${datashare}/${gse}/SRR9016936_1_trimmed_bismark_bt2_sorted.bam \






























