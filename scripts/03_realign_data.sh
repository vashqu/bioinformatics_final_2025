#!/bin/bash

REFERENCE="/mnt/hdd_b/home/user02/reference/hg38/hg38_chrom11.fa"
DATA_DIR="/mnt/hdd_b/home/user02/data/"
OUTPUT_DIR="/mnt/hdd_b/home/user02/output/"
BWA_INDEX="$REFERENCE"

SAMTOOLS="/usr/bin/samtools"
BWA="/usr/bin/bwa"

for BAM_FILE in $DATA_DIR/HG*/exome_alignment/*.bam; do
    SAMPLE=$(basename $BAM_FILE .bam)

    SAMPLE_OUTPUT_DIR="$OUTPUT_DIR/$SAMPLE"
    mkdir -p $SAMPLE_OUTPUT_DIR

    echo "Converting BAM to FASTQ for $SAMPLE..."
    $SAMTOOLS fastq \
        -1 $SAMPLE_OUTPUT_DIR/${SAMPLE}_R1.fastq \
        -2 $SAMPLE_OUTPUT_DIR/${SAMPLE}_R2.fastq \
        -s $SAMPLE_OUTPUT_DIR/${SAMPLE}_singletons.fastq \
        -0 /dev/null \
        -n $BAM_FILE

    echo "Aligning FASTQ for $SAMPLE to reference genome (chr11)..."
    $BWA mem -t 4 $BWA_INDEX \
        $SAMPLE_OUTPUT_DIR/${SAMPLE}_R1.fastq \
        $SAMPLE_OUTPUT_DIR/${SAMPLE}_R2.fastq > $SAMPLE_OUTPUT_DIR/${SAMPLE}.sam

    echo "Converting and sorting SAM to BAM for $SAMPLE..."
    $SAMTOOLS view -bS $SAMPLE_OUTPUT_DIR/${SAMPLE}.sam | \
        $SAMTOOLS sort -o $SAMPLE_OUTPUT_DIR/${SAMPLE}_sorted.bam

    echo "Indexing BAM for $SAMPLE..."
    $SAMTOOLS index $SAMPLE_OUTPUT_DIR/${SAMPLE}_sorted.bam

    echo "Cleaning up intermediate files for $SAMPLE..."
    rm $SAMPLE_OUTPUT_DIR/${SAMPLE}.sam
    rm $SAMPLE_OUTPUT_DIR/${SAMPLE}_R1.fastq
    rm $SAMPLE_OUTPUT_DIR/${SAMPLE}_R2.fastq
    rm $SAMPLE_OUTPUT_DIR/${SAMPLE}_singletons.fastq

    echo "Processing completed for $SAMPLE."
done

echo "All samples processed."


