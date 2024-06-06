# source ../01_preprocessing.sh first lines...
ssh cargo

# Transfering files
cd ~/projects/datashare/${gse}/
ls -lha raw/*Grn.idat raw/*Red.idat
cat raw/md5.bettik.txt 
mkdir -p /bettik/chuffarf/geo_submission/${project}/${gse}/idat
rsync -auvP --copy-links \
  ~/projects/datashare/${gse}/raw/*Grn.idat \
  ~/projects/datashare/${gse}/raw/*Red.idat \
  /bettik/chuffarf/geo_submission/${project}/${gse}/idat/.

ls -lha /bettik/chuffarf/geo_submission/${project}/${gse}/*
ls -lha /bettik/chuffarf/geo_submission/${project}/${gse}/idat/

# MD5
cd /bettik/chuffarf/geo_submission/${project}/${gse}/idat
md5sum *.idat > md5.geo.txt

ls -lha /bettik/chuffarf/geo_submission/${project}/${gse}/*
ls -lha /bettik/chuffarf/geo_submission/${project}/${gse}/idat/

# Put metadata
source ~/conda_config.sh 
conda activate rnaseq_env
cd ~/projects/${project}/results/${gse}/geo_submission
Rscript generate_metadata.R 

rsync -auvP cargo:~/projects/${project}/results/${gse}/geo_submission/0*_*.xlsx ~/projects/${project}/results/${gse}/geo_submission/.


# localy 
cd ~/projects/${project}/results/${gse}/geo_submission
# wget https://www.ncbi.nlm.nih.gov/geo/info/examples/seq_template.xlsx
open seq_template.xlsx

rsync -auvP seq_template.xlsx cargo:/bettik/chuffarf/geo_submission/${project}/${gse}/.

# Creating archive
cd /bettik/chuffarf/geo_submission/${gse}/
ls -lha ${GSE_TARGET_NAME}/*
 
tar -cvf ${GSE_TARGET_NAME}.tar ${GSE_TARGET_NAME}


# Put on GEO
ssh cargo
cd /bettik/chuffarf/geo_submission/${gse}/
lftp -e "mirror -R archive4geo uploads/florent.chuffart@univ-grenoble-alpes.fr_XXXHASHXXX " -u geoftp,XXXpasswrdXXX ftp-private.ncbi.nlm.nih.gov

