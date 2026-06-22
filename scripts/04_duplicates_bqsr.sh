#!/bin/bash

REFERENCE="/mnt/hdd_b/home/user02/reference/hg38/hg38_chrom11.fa"
KNOWN_SITES_MILLS="/mnt/hdd_b/home/user02/reference/hg38/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
KNOWN_SITES_HAPMAP="/mnt/hdd_b/home/user02/reference/hg38/hapmap_3.3.hg38.vcf.gz"
OUTPUT_DIR="/mnt/hdd_b/home/user02/output"
TOOLS_DIR="/mnt/hdd_b/home/user02/tools/gatk-4.6.1.0/gatk"
PICARD_JAR="/mnt/hdd_b/home/user02/reference/hg38/picard.jar"

for BAM in $OUTPUT_DIR/*/*_sorted.bam; do
    SAMPLE_NAME=$(basename $BAM _sorted.bam)
    SAMPLE_DIR=$(dirname $BAM)

    echo "Processing sample: $SAMPLE_NAME"

    # Add Read Groups if missing
    echo "Adding read groups to $SAMPLE_NAME..."
    java -jar $PICARD_JAR AddOrReplaceReadGroups \
        I=$BAM \
        O=$SAMPLE_DIR/${SAMPLE_NAME}_with_RG.bam \
        RGID=$SAMPLE_NAME \
        RGLB=lib1 \
        RGPL=ILLUMINA \
        RGPU=unit1 \
        RGSM=$SAMPLE_NAME

    # Index the BAM with read groups
    samtools index $SAMPLE_DIR/${SAMPLE_NAME}_with_RG.bam

    # Mark Duplicates
    echo "Marking duplicates for $SAMPLE_NAME..."
    gatk MarkDuplicates \
        -I $SAMPLE_DIR/${SAMPLE_NAME}_with_RG.bam \
        -O $SAMPLE_DIR/${SAMPLE_NAME}_marked_duplicates.bam \
        -M $SAMPLE_DIR/${SAMPLE_NAME}_marked_dup_metrics.txt \
        --CREATE_INDEX true

    # Base Recalibration
    echo "Running BaseRecalibrator for $SAMPLE_NAME..."
    gatk BaseRecalibrator \
        -R $REFERENCE \
        -I $SAMPLE_DIR/${SAMPLE_NAME}_marked_duplicates.bam \
        --known-sites $KNOWN_SITES_MILLS \
        --known-sites $KNOWN_SITES_HAPMAP \
        -O $SAMPLE_DIR/${SAMPLE_NAME}_recal_data.table

    # Apply Recalibration
    echo "Applying BQSR for $SAMPLE_NAME..."
    gatk ApplyBQSR \
        -R $REFERENCE \
        -I $SAMPLE_DIR/${SAMPLE_NAME}_marked_duplicates.bam \
        --bqsr-recal-file $SAMPLE_DIR/${SAMPLE_NAME}_recal_data.table \
        -O $SAMPLE_DIR/${SAMPLE_NAME}_recalibrated.bam

    # Index the recalibrated BAM
    echo "Indexing recalibrated BAM for $SAMPLE_NAME..."
    samtools index $SAMPLE_DIR/${SAMPLE_NAME}_recalibrated.bam

    echo "Completed processing for $SAMPLE_NAME."
done

echo "All samples processed successfully."
