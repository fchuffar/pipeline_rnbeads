import os 
import re
import string
exec(open("config").read())
rwversion=version # patch for bug in target shell (reserved word)

def get_files(src_dir, src_suffix, dest_dir, dest_suffix):
  files = [f for f in os.listdir(os.path.expanduser(src_dir)) if re.match("^.*"+src_suffix+"$", f)]
  files = [x.replace(src_suffix, dest_suffix) for x in files ]
  return [os.path.expanduser(dest_dir+f) for f in files]

bam_files = get_files("/home/fchuffar/projects/datashare/"+gse+"/raw/", "_val_1.fq.gz", "/home/fchuffar/projects/datashare/"+gse+"/"+species+"_"+annotation+"_"+rwversion+".", "_val_1_bismark_bt2_pe_sorted.bam")
fastqc_files = get_files("/home/fchuffar/projects/datashare/"+gse+"/raw/", ".fastq.gz", "/home/fchuffar/projects/datashare/"+gse+"/raw/", "_fastqc.zip")
trim_files = get_files("/home/fchuffar/projects/datashare/"+gse+"/raw/", "1.fastq.gz", "/home/fchuffar/projects/datashare/"+gse+"/raw/", "1_val_1.fq.gz")
bw_files = get_files("/home/fchuffar/projects/datashare/"+gse+"/raw/", "_val_1.fq.gz", "/home/fchuffar/projects/datashare/"+gse+"/"+species+"_"+annotation+"_"+rwversion+".", "_val_1_bismark_bt2_pe_sorted_4_RPKM.bw")
bw_bedgraph_files = get_files("/home/fchuffar/projects/datashare/"+gse+"/raw/", "_val_1.fq.gz", "/home/fchuffar/projects/datashare/"+gse+"/"+species+"_"+annotation+"_"+rwversion+".", "_val_1_bismark_bt2_pe_sortedbyname.bedGraph.bw")



localrules: target
rule target:
    threads: 1
    message: "-- Rule target completed. --"
    input: 
      "/home/fchuffar/projects/datashare/genomes/"+species+"/"+annotation+"/"+rwversion+"/Sequence/WholeGenomeFasta/Bisulfite_Genome",
      fastqc_files,
      trim_files,
      bam_files,
      bw_files,
      bw_bedgraph_files,


     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467835_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467836_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467837_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467838_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467839_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467840_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467841_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467842_1_fastqc.zip",
     # "/home/fchuffar/projects/datashare/GSE80959/raw/SRR3467843_1_fastqc.zip",
     #
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467835_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467836_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467837_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467838_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467839_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467840_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467841_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467842_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     # "/home/fchuffar/projects/datashare/GSE80959/SRR3467843_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",

    shell:"""
multiqc --force -o /home/fchuffar/projects/datashare/"""+gse+"""/ -n multiqc_rrbs \
  /home/fchuffar/projects/datashare/"""+gse+"""/*.txt \
  /home/fchuffar/projects/datashare/"""+gse+"""/raw/*_fastqc.zip \

echo workflow \"align_heatshock\" completed at `date` 
          """
rule fastqc:
    input:  fastqgz="{prefix}.fastq.gz"
    output: zip="{prefix}_fastqc.zip",
            html="{prefix}_fastqc.html"
    threads: 1
    shell:"""
export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH"
fastqc {input.fastqgz}
    """
              
rule bigwig_coverage:
    input:
      bam_file="{prefix}.bam",
    output: "{prefix}_{width}_{normalize}.bw"
    threads: 4
    shell:"""
export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH"
bamCoverage \
  -b {input.bam_file} \
  --numberOfProcessors `echo "$(({threads} * 2))"` \
  --binSize {wildcards.width} \
  --minMappingQuality 30 \
  --normalizeUsing {wildcards.normalize} \
  -o {output}
    """
    
rule trim_with_trim_galore_PE:
    input:
        fq_gz_f="{prefix}/{sample}_R1.fastq.gz",
        fq_gz_r="{prefix}/{sample}_R2.fastq.gz",
    output:
        trimed_fq_gz_f="{prefix}/{sample}_R1_val_1.fq.gz",
        trimed_fq_gz_r="{prefix}/{sample}_R2_val_2.fq.gz"
    threads: 4
    shell:"""
export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH"
trim_galore --cores {threads} --fastqc --paired {input.fq_gz_f} {input.fq_gz_r} -o {wildcards.prefix}/
    """

rule align_PE_with_bismark:
    input:
      trimed_fq_gz_f="{prefix}/raw/{sample}_R1_val_1.fq.gz",
      trimed_fq_gz_r="{prefix}/raw/{sample}_R2_val_2.fq.gz",
      bisulfite_genome_dir="/home/fchuffar/projects/datashare/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/Bisulfite_Genome"
    output:
      bam="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_pe_sorted.bam",
      bai="{prefix}/{species}_{annotation}_{version}.{sample}_R1_val_1_bismark_bt2_pe_sorted.bam.bai"
    threads: 16
    shell:    """
export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH"
cd {wildcards.prefix}/
bismark --multicore `echo "$(({threads} / 2))"` -n 1 ~/projects/datashare/genomes/{wildcards.species}/{wildcards.annotation}/{wildcards.version}/Sequence/WholeGenomeFasta/ \
  --prefix {wildcards.species}_{wildcards.annotation}_{wildcards.version} \
  -1 {input.trimed_fq_gz_f} \
  -2 {input.trimed_fq_gz_r}
samtools sort -@ {threads} -T /dev/shm/{wildcards.sample} -o  {wildcards.prefix}/{wildcards.species}_{wildcards.annotation}_{wildcards.version}.{wildcards.sample}_R1_val_1_bismark_bt2_pe_sorted.bam {wildcards.prefix}/{wildcards.species}_{wildcards.annotation}_{wildcards.version}.{wildcards.sample}_R1_val_1_bismark_bt2_pe.bam
rm {wildcards.prefix}/{wildcards.species}_{wildcards.annotation}_{wildcards.version}.{wildcards.sample}_R1_val_1_bismark_bt2_pe.bam
samtools index {output.bam}
              """




rule extract_meth_info_PE:
    input:  
      bam="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sorted.bam",
      chrom_sizes="/home/fchuffar/projects/datashare/genomes/"+species+"/"+annotation+"/"+rwversion+"/"+rwversion+".chrom.sizes",
    output:
      sortedbyname_bam="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bam",
      splitting_report="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname_splitting_report.txt",
      mbias_txt       ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.M-bias.txt",
      bedgraph_gz     ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.gz",
      bedgraph_bw     ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph.bw",
      cov_gz          ="{prefix}/{sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz",
    threads: 32
    shell:"""
# cd /summer/epistorage/datashare/temporize_rrbs_mgx/
# samtools sort -n -@ 16 -T /dev/shm/17_S7_L001_R1_001_trimmed_bismark_bt2_sorted -o 17_S7_L001_R1_001_trimmed_bismark_bt2_sortedbyname.bam 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam
# bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore 16 17_S7_L001_R1_001_trimmed_bismark_bt2_sortedbyname.bam
export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH"
cd {wildcards.prefix}
samtools sort -n -@ `echo "$(({threads} / 2))"` -T /dev/shm/{wildcards.sample} -o {output.sortedbyname_bam} {input.bam}
bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore {threads} {output.sortedbyname_bam}
gzip -d -k {output.bedgraph_gz}
bedGraphToBigWig {wildcards.prefix}/{wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph {input.chrom_sizes} {output.bedgraph_bw}
rm {wildcards.prefix}/{wildcards.sample}_R1_val_1_bismark_bt2_pe_sortedbyname.bedGraph

    """
# bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore 24 test.wgbs.sortedbyname.bam




rule bismark_genome_preparation:
    input:
        genome_fasta_dir="{prefix}/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/",
    output:
        bisulfite_genome_dir=directory("{prefix}/genomes/{species}/{annotation}/{version}/Sequence/WholeGenomeFasta/Bisulfite_Genome"),
    threads: 32
    shell:"""
export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH""
bismark_genome_preparation --parallel `echo "$(({threads} / 2))"` --bowtie2 {input.genome_fasta_dir}
ls -lha {output.bisulfite_genome_dir}
    """



# rule trim_with_trim_galore_SR:
#     input:
#         fq_gz="{prefix}/raw/{sample}.fastq.gz",
#     output:
#         trimmed_fggz    ="{prefix}/{sample}_trimmed.fq.gz",
#         trimmed_fqc_html="{prefix}/{sample}_trimmed_fastqc.html",
#         trimmed_fqczip  ="{prefix}/{sample}_trimmed_fastqc.zip",
#         trimmed_log     ="{prefix}/{sample}.fastq.gz_trimming_report.txt",
#     threads: 4
#     shell:"""
# # trim_galore --cores 4 --fastqc /summer/epistorage/datashare/temporize_rrbs_mgx/raw/17_S7_L001_R1_001.fastq.gz
# export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH""
# trim_galore --cores {threads} --fastqc {input.fq_gz} -o {wildcards.prefix}/
#     """

# rule align_SR_with_bismark:
#     input:
#       trimed_fq_gz="{prefix}/{sample}_trimmed.fq.gz",
#       bisulfite_genome_dir="/home/fchuffar/projects/datashare/genomes/"+species+"/"+annotation+"/"+rwversion+"/Sequence/WholeGenomeFasta/Bisulfite_Genome/",
#     output:
#       report=    "{prefix}/{sample}_trimmed_bismark_bt2_SE_report.txt",
#       bam=       "{prefix}/{sample}_trimmed_bismark_bt2.bam",
#       sorted_bam="{prefix}/{sample}_trimmed_bismark_bt2_sorted.bam",
#       sorted_bai="{prefix}/{sample}_trimmed_bismark_bt2_sorted.bam.bai",
#     threads: 16
#     shell:    """
# # cd /summer/epistorage/datashare/temporize_rrbs_mgx/
# # bismark --multicore 8 -n 1 /home/fchuffar/projects/datashare/genomes/"""+species+"""/"""+annotation+"""/"""+rwversion+"""/Sequence/WholeGenomeFasta/ 17_S7_L001_R1_001_trimmed.fq.gz
# # samtools sort -@ 16 -T /dev/shm/17_S7_L001_R1_001_trimmed -o 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam 17_S7_L001_R1_001_trimmed_bismark_bt2.bam
# # # rm 17_S7_L001_R1_001_trimmed_bismark_bt2.bam
# # samtools index 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam
# export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH""
# cd {wildcards.prefix}/
# bismark --multicore `echo "$(({threads} / 2))"` -n 1 /home/fchuffar/projects/datashare/genomes/"""+species+"""/"""+annotation+"""/"""+rwversion+"""/Sequence/WholeGenomeFasta/ {input.trimed_fq_gz}
# samtools sort -@ {threads} -T /dev/shm/{wildcards.sample} -o {output.sorted_bam} {output.bam}
# # rm {output.bam}
# samtools index {output.sorted_bam}
#               """

# rule extract_meth_info:
#     input:  "{prefix}/{sample}_trimmed_bismark_bt2_sorted.bam"
#     output:
#       sortedbyname_bam="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.bam",
#       splitting_report="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname_splitting_report.txt",
#       mbias_txt       ="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.M-bias.txt",
#       bedgraph_gz     ="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.bedGraph.gz",
#       cov_gz          ="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
#     threads: 8
#     shell:"""
# # cd /summer/epistorage/datashare/temporize_rrbs_mgx/
# # samtools sort -n -@ 16 -T /dev/shm/17_S7_L001_R1_001_trimmed_bismark_bt2_sorted -o 17_S7_L001_R1_001_trimmed_bismark_bt2_sortedbyname.bam 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam
# # bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore 16 17_S7_L001_R1_001_trimmed_bismark_bt2_sortedbyname.bam
# export PATH="/summer/epistorage/miniconda3/envs/rrbs_env/bin/:$PATH""
# cd {wildcards.prefix}
# samtools sort -n -@ {threads} -T /dev/shm/{wildcards.sample} -o {output.sortedbyname_bam} {input}
# bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore {threads} {output.sortedbyname_bam}
#     """
