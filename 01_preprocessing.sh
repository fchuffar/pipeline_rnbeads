cd ~/projects/temporise/results/GSE130735
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

# launch RnBeads
ssh dahu
oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:\$PATH; cd ~/projects/${project}/results/${gse}; Rscript 02_rnbeads_go.R";

# differential analysis
