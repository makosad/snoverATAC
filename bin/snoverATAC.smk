#### For demultiplexing the run 
#### Demultiplex with the following command by the Tn5 index and i7 index:
# /bin/nice -n 5 bcl2fastq --sample-sheet samplesheet_demux_snoverATAC.csv --use-bases-mask Y*,I*,Y30I10,Y* --no-lane-splitting -o fastqs
# change the data so that:
# ls data | grep _R1_ | sed s,'R1_001.fastq.gz',,g | xargs -n1 -P40 -I{} sh -c '/bin/nice -n 5 mv data/{}R1_001.fastq.gz data/{}L001_R1_001.fastq.gz' &
# ls data | grep _R3_ | sed s,'R3_001.fastq.gz',,g | xargs -n1 -P40 -I{} sh -c '/bin/nice -n 5 mv data/{}R3_001.fastq.gz data/{}L001_R2_001.fastq.gz' &
# conda activate gdepleted
# ls data | grep R2 | grep -v L001 | sed s,'R2_001.fastq.gz',,g | xargs -n1 -P45 -I{} sh -c '/bin/nice -n 5 zcat data/{}R2_001.fastq.gz | fastx_trimmer -l 16 -o data/{}L001_I2_001.fastq.gz -z' &
# ls data | grep -v L001 | xargs -n1 -P90 -I{} sh -c '/bin/nice -n 5 rm data/{}'


#### To get sample names for config file with:
# ls data/*gz | sed s,'_[RI][1-3].*',,g | sed s,'data/','  - ',g | uniq 


#### Run this pipeline with:
# /bin/nice -n10 snakemake -s /home/dmakosa/working_data_04/scifi/bin/scifiRNAseq.smk --use-conda --default-resources "tmpdir='/scratchfs/dmakosa/tmp'" --cores 80

#### To view csv files:
# column -t -s','

#### To get the mapping summary run:
# cat <(cat <(echo -e "Sample") <(cat output/2.mapped/raw/RL4510_H02_S182/RL4510_H02_S182_Solo.out/GeneFull/Summary.csv | cut -f1 -d,) | tr '\n' ',' | sed "s/$/\n/") \
# <(for i in output/2.mapped/raw/*; do echo ${i/output*\//} | tr '\n' ','; cat $i/${i/output*\//}_Solo.out/GeneFull/Summary.csv | cut -f2 -d, | tr '\n' ',' | sed "s/$/\n/"; done) \
# > mapping.summary.csv

#### To get the ribosomal read mapping summary:
# cat <(echo -e "Sample,mappedReads,mappedToRibosomal,FractionRibosomal") \
# <(for i in output/0.logs/ReadCount_*.no; do echo ${i/output*ReadCount_/} | sed s,'.no',, | tr '\n' ','; cat $i | tr '\n' ',' ; cat ${i/.no/.ribosomal_no} | tr '\n' ','  | sed "s/$/\n/" ; done | awk 'BEGIN {FS=","; OFS=","} {$4=$3/$2*100; print}') \
# > ribosomalMapped.summary.csv

#### To get the RNAmetrics summary run:
# cat <(echo -e "Sample,PCT_R1_TRANSCRIPT_STRAND_READS,PCT_R2_TRANSCRIPT_STRAND_READS,PCT_CODING_BASES,PCT_UTR_BASES,PCT_INTRONIC_BASES,PCT_INTERGENIC_BASES,PCT_MRNA_BASES,PCT_USABLE_BASES") \
# <(for i in output/3.RNAMetrics/*firstStrand; do echo ${i/output*\//} | sed s,'.RNA_Metrics_firstStrand',, | tr '\n' ','; cat $i | grep PF_BASES -A1 | cut -f14,15,17-22 | tail -n1 | tr '\t' ','; done) \
# > RNAMetrics.summary.csv

### To plot the mapping summary:
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Median UMI per Cell'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Median GeneFull per Cell'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Fraction of Unique Reads in Cells'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Sequencing Saturation'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Estimated Number of Cells'

# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perSaturation.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Median UMI per Cell'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perSaturation.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Median GeneFull per Cell'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perSaturation.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Fraction of Unique Reads in Cells'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perSaturation.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Estimated Number of Cells'

# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perNoOfCells.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Median UMI per Cell'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perNoOfCells.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Median GeneFull per Cell'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perNoOfCells.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Fraction of Unique Reads in Cells'
# python /home/dmakosa/working_data_04/scifi/plots/mapping_summary_perNoOfCells.py /home/dmakosa/working_data_02/scifiRNAseq/mapping.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'Estimated Number of Cells'

# python /home/dmakosa/working_data_04/scifi/plots/ribosomal_summary.py /home/dmakosa/working_data_02/scifiRNAseq/ribosomalMapped.summary.csv /home/dmakosa/working_data_02/scifiRNAseq/plots 'FractionRibosomal'

# ---- DICTIONARIES ---- #
configfile: "/home/dmakosa/working_data_04/scifi/bin/config.yaml"
index = config["index"] 
adapter_sequences = config["adapter_sequences"]
contaminant_sequences = config["contaminant_sequences"]
fastqc_limits = config["fastqc_limits"]
cellbarcode_list = config["cellbarcode_list"]
reflat = config["reflat"]
rRNA_flanking = config["rRNA_flanking"]

# ---- SCRIPTS ---- #
cbumi = "/home/dmakosa/working_data_04/scifi/bin/combine_cb_umi_scifiRNAseq.py"

# ---- TARGET RULE ---- # 
rule all:
    input:
        ".mkdir.chkpnt",
        # Preprocessing:
        expand("output/0.logs/logPreQCs_{sample}.log", sample=config["samples"]),
        # Mapping:
        expand("output/0.logs/logStarsolo_{sample}.log", sample=config["samples"]),
        expand("output/3.RNAMetrics/{sample}.RNA_Metrics_firstStrand", sample=config["samples"]),
        expand("output/0.logs/ReadCount_{sample}.ribosomal_no", sample=config["samples"]),
        expand("output/0.logs/ReadCount_{sample}.no", sample=config["samples"])
    message: "Target rule"


# ---- RULES ---- # 

# ---- PRE-PROCESSING ---- # 
rule makedir:
    output: ".mkdir.chkpnt"
    params: 
        "output/0.logs/",
        "output/0.5.data.cbumi/",
        "output/1.fastqc/raw/",
        "output/2.mapped/raw/",
        "output/3.RNAMetrics"
    message: "creating directories..."
    threads: 1
    shell: "mkdir -p {params}; touch {output}"

rule create_CBumi_fastq:
    input:
        umiRead = "data/{sample}_I1_001.fastq.gz",
        cbRead = "data/{sample}_R1_001.fastq.gz",
        mkdir_check = ancient(".mkdir.chkpnt")
    output: "output/0.5.data.cbumi/{sample}_CBUMI_001.fastq.gz"
    message: "Gather CBUMI into one fastq file for mapping with starsolo; sample: {wildcards.sample}; files: {input.umiRead} {input.cbRead}"
    threads: 2
    shell: "python {cbumi} {input.umiRead} {input.cbRead} | gzip > {output}"

rule fastqc_raw_reads:
    input:
        fq1 = "output/0.5.data.cbumi/{sample}_CBUMI_001.fastq.gz",
        fq2 = "data/{sample}_R2_001.fastq.gz",
        mkdir_check = ancient(".mkdir.chkpnt")
    output: "output/0.logs/logPreQCs_{sample}.log"
    params: 
        kmers = "10"
    message: "QC of raw reads on sample {wildcards.sample} files {input.fq1} {input.fq2}"
    threads: 1
    conda:
        "10xmethylomes"
    shell: "fastqc -o output/1.fastqc/raw/ {input.fq1} {input.fq2} --adapters {adapter_sequences} --contaminants {contaminant_sequences} --limits {fastqc_limits} --kmers {params.kmers} --threads 40 > {output}"

rule starsolo_mapping:
    input:
        cbumi = "output/0.5.data.cbumi/{sample}_CBUMI_001.fastq.gz",
        mapping = "data/{sample}_R2_001.fastq.gz",
        mkdir_check = ancient(".mkdir.chkpnt")
    output: 
        log = "output/0.logs/logStarsolo_{sample}.log",
        bam = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam",
        unmapped = "output/2.mapped/raw/{sample}/{sample}_Unmapped.out.mate1"
    message: "Mapping of sample {wildcards.sample} files {input.mapping} {input.cbumi}"
    params:
        "output/2.mapped/raw/{sample}/{sample}_"
    conda:
        "starsolo"
    threads: 10
    shell:
        "STAR --runThreadN {threads} --runMode alignReads --genomeDir {index} --readFilesIn {input.mapping} {input.cbumi} --readFilesCommand zcat "
        "--clip3pAdapterSeq AAAAAAAAAAAAAAAAAAAA "
        "--outSAMtype BAM SortedByCoordinate --outSAMattributes CB UB "
        "--outSAMunmapped Within "
        "--soloFeatures GeneFull "
        "--outFilterIntronMotifs RemoveNoncanonical --outReadsUnmapped Fastx  "
        " --outFileNamePrefix {params} "
        "--soloCBstart 1 --soloCBlen 16 --soloUMIstart 17 --soloUMIlen 8 "
        "--soloType CB_UMI_Simple --soloCBwhitelist {cellbarcode_list} 2>&1 > {output.log}"

rule indx_bam_raw:
    input: 
        bam_raw = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam",
        mkdir_check = ancient(".mkdir.chkpnt")
    output:
        bam_raw = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam.bai"
    message: "Index the bam file for sample# {wildcards.sample}"
    threads: 1
    conda:
        "bulkatac"
    shell: "samtools index {input.bam_raw}"

rule read_metrics_firstStrand_raw:
    input: 
        bam = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam",
        bami = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam.bai",
        mkdir_check = ancient(".mkdir.chkpnt")
    output: "output/3.RNAMetrics/{sample}.RNA_Metrics_firstStrand"
    message: "RNA metrics for sample {wildcards.sample}"
    conda:
        "10xmethylomes"
    threads: 10
    shell: "picard -Xmx20g CollectRnaSeqMetrics I={input.bam} O={output} REF_FLAT={reflat} STRAND=FIRST_READ_TRANSCRIPTION_STRAND"

rule countReadsInrRNA:
    input:
        bam = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam",
        bami = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam.bai",
        mkdir_check = ancient(".mkdir.chkpnt")
    output: 
        readcount = "output/0.logs/ReadCount_{sample}.ribosomal_no"
    message: "Output the read names overlapping rRNA for {wildcards.sample}"
    threads: 1
    conda:
        "bulkatac"
    shell: "samtools view -F260 -cL {rRNA_flanking} {input.bam} > {output}"

rule countReadsOverall:
    input:
        bam = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam",
        bami = "output/2.mapped/raw/{sample}/{sample}_Aligned.sortedByCoord.out.bam.bai",
        mkdir_check = ancient(".mkdir.chkpnt")
    output: 
        readcount = "output/0.logs/ReadCount_{sample}.no"
    message: "Output the read names overlapping rRNA for {wildcards.sample}"
    threads: 1
    conda:
        "bulkatac"
    shell: "samtools view -F260 -c {input.bam} > {output}"