# retrieve fastq
source config

ssh cargo

mkdir -p ~/projects/${datashare}/${gse}/raw
cd ~/projects/${datashare}/${gse}/raw

for srr in SRR9016929 SRR9016930 SRR9016931 SRR9016934 SRR9016935 SRR9016936
do
  echo ${srr}
  prefetch $srr
  vdb-validate $srr
  parallel-fastq-dump --threads 16 --tmpdir /dev/shm --gzip --split-files --outdir ./ --sra-id ${srr}
done

exit 

cd ~/projects/${project}/results/${gse}
rsync -auvP ~/projects/${project}/results/${gse}/ cargo:~/projects/${project}/results/${gse}/

ssh dahu

cd ~/projects/${project}/results/${gse}
snakemake -s ~/projects/${project}/results/${gse}/wf_rrbs.py --cores 50 --cluster "oarsub --project epimed -l nodes=1/core={threads},walltime=6:00:00 " --latency-wait 60 -pn


oarsub --project epimed  -l /nodes=1,core=32,walltime=06:00:00 "export PATH=/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH; cd ~/projects/${project}/results/${gse}; Rscript 02_rnbeads_go.R";






















