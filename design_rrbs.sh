cd ~/projects/datashare/${gse}/
ls -lha *.cov.gz

ln -s Homo_sapiens_UCSC_hg19.HCT116-5-Azacytidine-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz  HCT11_5Aza-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-AMSA2-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz          HCT11_AMSA-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-AMSA2-30uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz          HCT11_AMSA-30uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-Extract-0-1_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz         HCT11_Extr-00uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-MPB7-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz           HCT11_MPB7-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-MPB7-30uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz           HCT11_MPB7-30uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-UM63-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz           HCT11_UM63-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HCT116-untreated_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz           HCT11_untr_00uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-5-Azacytidine-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz   HaCat_5Aza-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-AMSA2-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz           HaCat_AMSA-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-AMSA2-30uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz           HaCat_AMSA-30uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-Extract-0-1_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz          HaCat_Extr-00uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-MPB7-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz            HaCat_MPB7-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-MPB7-30uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz            HaCat_MPB7-30uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-UM63-10uM_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz            HaCat_UM63-10uM.cov.gz
ln -s Homo_sapiens_UCSC_hg19.HaCat-untreated_R1_val_1_bismark_bt2_pe_sortedbyname.bismark.cov.gz            HaCat_untr_00uM.cov.gz


cd ~/projects/${project}/results/${gse}/

echo "bed_file;sampleID;cell_line;cofactor;treatment"               > sample.txt
echo "HCT11_5Aza-10uM.cov.gz;HCT11_5Aza-10uM;HCT11;5Aza-10uM;5Aza" >> sample.txt
echo "HCT11_AMSA-10uM.cov.gz;HCT11_AMSA-10uM;HCT11;AMSA-10uM;Othr" >> sample.txt
echo "HCT11_AMSA-30uM.cov.gz;HCT11_AMSA-30uM;HCT11;AMSA-30uM;Othr" >> sample.txt
echo "HCT11_Extr-00uM.cov.gz;HCT11_Extr-00uM;HCT11;Extr-00uM;Othr" >> sample.txt
echo "HCT11_MPB7-10uM.cov.gz;HCT11_MPB7-10uM;HCT11;MPB7-10uM;Othr" >> sample.txt
echo "HCT11_MPB7-30uM.cov.gz;HCT11_MPB7-30uM;HCT11;MPB7-30uM;Othr" >> sample.txt
echo "HCT11_UM63-10uM.cov.gz;HCT11_UM63-10uM;HCT11;UM63-10uM;Othr" >> sample.txt
echo "HCT11_untr_00uM.cov.gz;HCT11_untr_00uM;HCT11;untr_00uM;Othr" >> sample.txt
echo "HaCat_5Aza-10uM.cov.gz;HaCat_5Aza-10uM;HaCat;5Aza-10uM;5Aza" >> sample.txt
echo "HaCat_AMSA-10uM.cov.gz;HaCat_AMSA-10uM;HaCat;AMSA-10uM;Othr" >> sample.txt
echo "HaCat_AMSA-30uM.cov.gz;HaCat_AMSA-30uM;HaCat;AMSA-30uM;Othr" >> sample.txt
echo "HaCat_Extr-00uM.cov.gz;HaCat_Extr-00uM;HaCat;Extr-00uM;Othr" >> sample.txt
echo "HaCat_MPB7-10uM.cov.gz;HaCat_MPB7-10uM;HaCat;MPB7-10uM;Othr" >> sample.txt
echo "HaCat_MPB7-30uM.cov.gz;HaCat_MPB7-30uM;HaCat;MPB7-30uM;Othr" >> sample.txt
echo "HaCat_UM63-10uM.cov.gz;HaCat_UM63-10uM;HaCat;UM63-10uM;Othr" >> sample.txt
echo "HaCat_untr_00uM.cov.gz;HaCat_untr_00uM;HaCat;untr_00uM;Othr" >> sample.txt

