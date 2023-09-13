mkdir /dd_rundata/novaseq/Runs/230831_A00690_H5JKMDRX3_126
chmod 777 -R /dd_rundata/novaseq/Runs/230831_A00690_H5JKMDRX3_126
rsync -ahPr --exclude Thumbnail_Images * /dd_rundata/novaseq/Runs/230831_A00690_H5JKMDRX3_126 > /dd_rundata/novaseq/Runs/230831_A00690_H5JKMDRX3_126/copy.log

/bin/nice -n 5 bcl2fastq --sample-sheet samplesheet_demux_snoverATAC.csv --use-bases-mask Y*,I*,Y30I10,Y* --no-lane-splitting -o fastqs
ls /dd_rundata/novaseq/Runs/230831_A00690_H5JKMDRX3_126/fastqs/CRT_snoverATAC/ | xargs -n1 -P90 -I{} sh -c 'cp /dd_rundata/novaseq/Runs/230831_A00690_H5JKMDRX3_126/fastqs/CRT_snoverATAC/{} /home/dmakosa/working_data_02/snoverATAC/data/{}'
ls data | grep _R1_ | sed s,'R1_001.fastq.gz',,g | xargs -n1 -P40 -I{} sh -c '/bin/nice -n 5 mv data/{}R1_001.fastq.gz data/{}L001_R1_001.fastq.gz' &
ls data | grep _R3_ | sed s,'R3_001.fastq.gz',,g | xargs -n1 -P40 -I{} sh -c '/bin/nice -n 5 mv data/{}R3_001.fastq.gz data/{}L001_R2_001.fastq.gz' &
conda activate gdepleted
ls data | grep R2 | grep -v L001 | sed s,'R2_001.fastq.gz',,g | xargs -n1 -P45 -I{} sh -c '/bin/nice -n 5 zcat data/{}R2_001.fastq.gz | fastx_trimmer -l 16 -o data/{}L001_I2_001.fastq.gz -z' &
ls data | grep -v L001 | xargs -n1 -P90 -I{} sh -c '/bin/nice -n 5 rm data/{}'
mkdir output
ls ../data | sed s,'_S.'*,,g | uniq | xargs -n1 -P19 -I{} sh -c '/bin/nice -n 5 /home/dmakosa/working_data_01/apps/cellranger-atac-2.0.0/cellranger-atac count --id {} --sample {} --reference /home/dmakosa/working_data_01/apps/10x_referencefiles/refdata-cellranger-atac-GRCh38-and-mm10-2020-A-2.0.0 --fastqs ../data --localcores 5'

cat RL4632_*I2_001.fastq.gz > combinedRL4632_S0_L001_I2_001.fastq.gz &
cat RL4632_*R1_001.fastq.gz > combinedRL4632_S0_L001_R1_001.fastq.gz &
cat RL4632_*R2_001.fastq.gz > combinedRL4632_S0_L001_R2_001.fastq.gz &

/bin/nice -n 10 /home/dmakosa/working_data_01/apps/cellranger-atac-2.0.0/cellranger-atac count --id combinedRL4632 --sample combinedRL4632 --reference /home/dmakosa/working_data_01/apps/10x_referencefiles/refdata-cellranger-atac-GRCh38-and-mm10-2020-A-2.0.0 --fastqs ../data --localcores 80
ls ../data/RL* | sed s,'_S.'*,,g | sed s,'../data/',,g | uniq | xargs -n1 -P19 -I{} sh -c '/bin/nice -n 5 /home/dmakosa/working_data_01/apps/cellranger-atac-2.0.0/cellranger-atac count --id {} --sample {} --reference /home/dmakosa/working_data_01/apps/10x_referencefiles/refdata-cellranger-atac-GRCh38-and-mm10-2020-A-2.0.0 --fastqs ../data --localcores 5 --peaks /home/dmakosa/working_data_02/snoverATAC/combinedRL4632/combinedRL4632/outs/peaks.bed'
# in /home/dmakosa/working_data_02/snoverATAC
ls combinedRL4632 | xargs -n1 -P1 -I{} sh -c 'cat combinedRL4632/{}/outs/summary.csv >> summary.csv'
ls RL3294_RL3295/cellranger_output_alltogether/RL*/outs/summary.csv | xargs -n1 -P1 -I{} sh -c 'cat {} >> summary.csv'
ls cellranger2/RL*/outs/summary.csv | xargs -n1 -P1 -I{} sh -c 'cat {} >> summary.csv'
cat summary.csv | sort | uniq > temp.summary.csv
cat temp.summary.csv | awk 'END{print}' >> final.summary.csv
head -n -1 temp.summary.csv >> final.summary.csv


ls ../data/RL* | sed s,'_S.'*,,g | sed s,'../data/',,g | uniq | xargs -n1 -P19 -I{} sh -c '/bin/nice -n 5 /home/dmakosa/working_data_01/apps/cellranger-atac-2.0.0/cellranger-atac count --id {} --sample {} --reference /home/dmakosa/working_data_01/apps/10x_referencefiles/refdata-cellranger-atac-GRCh38-and-mm10-2020-A-2.0.0 --fastqs ../data --localcores 5 --peaks /home/dmakosa/working_data_02/snoverATAC/cellranger2/RL3210_01_dirty_THS_30_shortREV_lowTn5/outs/peaks.bed'

ls RL4632_3210peaks | xargs -n1 -P1 -I{} sh -c 'cat RL4632_3210peaks/{}/outs/summary.csv >> summary2.csv'
ls RL3294_RL3295/cellranger_output/RL*/outs/summary.csv | xargs -n1 -P1 -I{} sh -c 'cat {} >> summary2.csv'
ls cellranger2/RL*/outs/summary.csv | xargs -n1 -P1 -I{} sh -c 'cat {} >> summary2.csv'
cat summary2.csv | sort | uniq > temp.summary2.csv
cat temp.summary2.csv | awk 'END{print}' >> final.summary2.csv
head -n -1 temp.summary2.csv >> final.summary2.csv


macs2 callpeak --nomodel --extsize 150 --shift -75 -t possorted_bam.bam -f BAM -n /home/dmakosa/working_data_02/snoverATAC/combinedRL4632/combinedRL4632_peakCall/combinedRL4632.NFR --gsize 5.83e9 --tempdir /scratchfs/dmakosa/tmp/

macs2 callpeak --nomodel --extsize 150 --shift -75 -t possorted_bam.bam -f BAM -n /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR --gsize 5.83e9 --tempdir /scratchfs/dmakosa/tmp/
cut -f1-3 /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.narrowPeak | sort -k 1,1 -k2,2n > /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.bed
sed '115985d' /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.bed > /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.modified.bed
awk '$1!="GRCh38_GL000205.2" {print}' /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.bed | awk '$1!="GRCh38_GL000216.2" {print}' | awk '$1!="GRCh38_GL000218.1" {print}'> /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.modified.bed
GRCh38_GL000219.1
awk '$1 !~ /GRCh38_GL/' /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.bed | awk '$1 !~ /GRCh38_KI/' |  awk '$1 !~ /mm10_GL/' |  awk '$1 !~ /mm10_JH/' > /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.modified.bed
ls ../data/RL3295_*gz | sed s,'_S.'*,,g | sed s,'../data/',,g | uniq | xargs -n1 -P19 -I{} sh -c '/bin/nice -n 5 /home/dmakosa/working_data_01/apps/cellranger-atac-2.0.0/cellranger-atac count --id {} --sample {} --reference /home/dmakosa/working_data_01/apps/10x_referencefiles/refdata-cellranger-atac-GRCh38-and-mm10-2020-A-2.0.0 --fastqs ../data/ --localcores 5 --peaks /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.bed'
cat /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.modified.bed | awk 'NR>115982 {print}' | head
cat /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.bed | grep GRCh38_GL000205.2 | wc -l
ls ../data/RL3295_*gz | sed s,'_S.'*,,g | sed s,'../data/',,g | uniq | xargs -n1 -P19 -I{} sh -c '/bin/nice -n 5 /home/dmakosa/working_data_01/apps/cellranger-atac-2.0.0/cellranger-atac count --id {} --sample {} --reference /home/dmakosa/working_data_01/apps/10x_referencefiles/refdata-cellranger-atac-GRCh38-and-mm10-2020-A-2.0.0 --fastqs ../data/ --localcores 5 --peaks /home/dmakosa/working_data_02/snoverATAC/RL3294_RL3295/RL3295bulk_peakCall/RL3295bulk.NFR_peaks.cellranger.modified.bed'