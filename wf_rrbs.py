def get_files(src_dir, src_suffix, dest_dir, dest_suffix):
  files = [f for f in os.listdir(src_dir) if re.match("^.*"+src_suffix+"$", f)]
  files = [x.replace(src_suffix, dest_suffix) for x in files ]
  return [os.path.join(dest_dir, f) for f in files]

localrules: target
rule target:
    threads: 1
    message: "-- Rule target completed. --"
    input: 
     "/home/fchuffar/projects/datashare/GSE130735/raw/SRR9016929_1_fastqc.zip",
     "/home/fchuffar/projects/datashare/GSE130735/raw/SRR9016930_1_fastqc.zip",
     "/home/fchuffar/projects/datashare/GSE130735/raw/SRR9016931_1_fastqc.zip",
     "/home/fchuffar/projects/datashare/GSE130735/raw/SRR9016934_1_fastqc.zip",
     "/home/fchuffar/projects/datashare/GSE130735/raw/SRR9016935_1_fastqc.zip",
     "/home/fchuffar/projects/datashare/GSE130735/raw/SRR9016936_1_fastqc.zip",

     "/home/fchuffar/projects/datashare/GSE130735/SRR9016929_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     "/home/fchuffar/projects/datashare/GSE130735/SRR9016930_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     "/home/fchuffar/projects/datashare/GSE130735/SRR9016931_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     "/home/fchuffar/projects/datashare/GSE130735/SRR9016934_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     "/home/fchuffar/projects/datashare/GSE130735/SRR9016935_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",
     "/home/fchuffar/projects/datashare/GSE130735/SRR9016936_1_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",

    shell:"""
multiqc --force -o /home/fchuffar/projects/datashare/temporize_rrbs_mgx/ -n multiqc_rrbs \
  /home/fchuffar/projects/datashare/temporize_rrbs_mgx/*.txt \
  /home/fchuffar/projects/datashare/temporize_rrbs_mgx/raw/*_fastqc.zip \

echo workflow \"align_heatshock\" completed at `date` 
          """
rule fastqc:
    input:  fastqgz="{prefix}.fastq.gz"
    output: zip="{prefix}_fastqc.zip",
            html="{prefix}_fastqc.html"
    threads: 1
    shell:"""
    export PATH="/summer/epistorage/miniconda3/bin:$PATH"
    /summer/epistorage/miniconda3/bin/fastqc {input.fastqgz}
    """
              
rule bigwig_coverage:
    input:
      bam_file="{prefix}.bam",
    output: "{prefix}_{width}_{normalize}.bw"
    threads: 4
    shell:"""
export PATH="/summer/epistorage/miniconda3/bin:$PATH"
bamCoverage \
  -b {input.bam_file} \
  --numberOfProcessors `echo "$(({threads} * 2))"` \
  --binSize {wildcards.width} \
  --minMappingQuality 30 \
  --normalizeUsing {wildcards.normalize} \
  -o {output}
    """
    
# rule trim_with_trim_galore_PE:
#     input:
#         fq_gz_f="{prefix}/{sample}_1.fastq.gz",
#         fq_gz_r="{prefix}/{sample}_2.fastq.gz",
#     output:
#         trimed_fq_gz_f="{prefix}/{sample}_1_val_1.fq.gz",
#         trimed_fq_gz_r="{prefix}/{sample}_2_val_2.fq.gz"
#     threads: 4
#     shell:"""
# export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
# trim_galore --cores {threads} --fastqc --paired --trim1 {input.fq_gz_f} {input.fq_gz_r} -o {wildcards.prefix}/
#     """

# rule align_PE_with_bismark:
#     input:
#       trimed_fq_gz_f="{prefix}/{sample}_1_val_1.fq.gz",
#       trimed_fq_gz_r="{prefix}/{sample}_2_val_2.fq.gz"
#     output:"{prefix}/{sample}_1_val_1_bismark_bt2_pe_sorted.bam"
#     threads: 16
#     shell:    """
# export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
# cd {wildcards.prefix}/
# bismark --multicore `echo "$(({threads} / 2))"` -n 1 ~/projects/datashare/genomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/ \
#   -1 {input.trimed_fq_gz_f} \
#     -2 {input.trimed_fq_gz_r}
# samtools sort -@ {threads} -T /dev/shm/{wildcards.sample} -o {wildcards.prefix}/{wildcards.sample}_1_val_1_bismark_bt2_pe_sorted.bam {wildcards.prefix}/{wildcards.sample}_1_val_1_bismark_bt2_pe.bam
# # rm {wildcards.prefix}/{wildcards.sample}_1_val_1_bismark_bt2_pe.bam
# samtools index {output}
#               """


rule trim_with_trim_galore_SR:
    input:
        fq_gz="{prefix}/raw/{sample}.fastq.gz",
    output:
        trimmed_fggz    ="{prefix}/{sample}_trimmed.fq.gz",
        trimmed_fqc_html="{prefix}/{sample}_trimmed_fastqc.html",
        trimmed_fqczip  ="{prefix}/{sample}_trimmed_fastqc.zip",
        trimmed_log     ="{prefix}/{sample}.fastq.gz_trimming_report.txt",
    threads: 4
    shell:"""
# trim_galore --cores 4 --fastqc /summer/epistorage/datashare/temporize_rrbs_mgx/raw/17_S7_L001_R1_001.fastq.gz    
export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
trim_galore --cores {threads} --fastqc {input.fq_gz} -o {wildcards.prefix}/
    """

# rule bismark_genome_preparation:
#     input:
#         genome_fasta_dir=directory("{prefix}/genomes/{species}/UCSC/{index}/Sequence/WholeGenomeFasta/"),
#     output:
#         bisulfit_genome_dir=directory("{prefix}/genomes/{species}/UCSC/{index}/Sequence/WholeGenomeFasta/Bisulfite_Genome/"),
#     threads: 32
#     shell:"""
# export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
# # bismark_genome_preparation --parallel 8 --bowtie2 ~/projects/datashare/genomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/
# # ls -lha ~/projects/datashare/genomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/Bisulfite_Genome/*
# # ls -lha ~/projects/datashare/genomes/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/Bisulfite_Genome/*
# bismark_genome_preparation --parallel `echo "$(({threads} / 2))"` --bowtie2 {input.genome_fasta_dir}
# ls -lha {output.bisulfit_genome_dir}
#     """

rule align_SR_with_bismark:
    input:
      trimed_fq_gz="{prefix}/{sample}_trimmed.fq.gz",
      # genome_fasta_dir=directory("/home/fchuffar/projects/datashare/genomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/"),
      bisulfit_genome_dir=directory("/home/fchuffar/projects/datashare/genomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/Bisulfite_Genome/"),
    output:
      report=    "{prefix}/{sample}_trimmed_bismark_bt2_SE_report.txt",
      bam=       "{prefix}/{sample}_trimmed_bismark_bt2.bam",
      sorted_bam="{prefix}/{sample}_trimmed_bismark_bt2_sorted.bam",
      sorted_bai="{prefix}/{sample}_trimmed_bismark_bt2_sorted.bam.bai",
    threads: 16
    shell:    """
# cd /summer/epistorage/datashare/temporize_rrbs_mgx/
# bismark --multicore 8 -n 1 /home/fchuffar/projects/datashare/genomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/ 17_S7_L001_R1_001_trimmed.fq.gz
# samtools sort -@ 16 -T /dev/shm/17_S7_L001_R1_001_trimmed -o 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam 17_S7_L001_R1_001_trimmed_bismark_bt2.bam
# # rm 17_S7_L001_R1_001_trimmed_bismark_bt2.bam
# samtools index 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam
export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
cd {wildcards.prefix}/
bismark --multicore `echo "$(({threads} / 2))"` -n 1 /home/fchuffar/projects/datashare/genomes/Mus_musculus/UCSC/mm10/Sequence/WholeGenomeFasta/ {input.trimed_fq_gz}
samtools sort -@ {threads} -T /dev/shm/{wildcards.sample} -o {output.sorted_bam} {output.bam} 
# rm {output.bam}
samtools index {output.sorted_bam}
              """

rule extract_meth_info:
    input:  "{prefix}/{sample}_trimmed_bismark_bt2_sorted.bam"
    output: 
      sortedbyname_bam="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.bam",
      splitting_report="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname_splitting_report.txt",
      mbias_txt       ="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.M-bias.txt",           
      bedgraph_gz     ="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.bedGraph.gz",          
      cov_gz          ="{prefix}/{sample}_trimmed_bismark_bt2_sortedbyname.bismark.cov.gz",       
    threads: 8
    shell:"""
# cd /summer/epistorage/datashare/temporize_rrbs_mgx/
# samtools sort -n -@ 16 -T /dev/shm/17_S7_L001_R1_001_trimmed_bismark_bt2_sorted -o 17_S7_L001_R1_001_trimmed_bismark_bt2_sortedbyname.bam 17_S7_L001_R1_001_trimmed_bismark_bt2_sorted.bam
# bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore 16 17_S7_L001_R1_001_trimmed_bismark_bt2_sortedbyname.bam
export PATH="/summer/epistorage/miniconda3/bin:/summer/epistorage/opt/bin:$PATH"
cd {wildcards.prefix}
samtools sort -n -@ {threads} -T /dev/shm/{wildcards.sample} -o {output.sortedbyname_bam} {input}
bismark_methylation_extractor --bedGraph --counts -s --no_overlap  --multicore {threads} {output.sortedbyname_bam}
    """    
