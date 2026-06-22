#!/bin/bash

echo "Starting HaplotypeCaller"

REFERENCE="/mnt/hdd_b/home/user02/reference/hg38/hg38_chrom11.fa"
OUTPUT_DIR="/mnt/hdd_b/home/user02/output"

# Loop through recalibrated BAM files
for bam_file in $OUTPUT_DIR/*/*_recalibrated.bam
do
    sample_name=$(basename $bam_file _recalibrated.bam)
    sample_output_dir="$OUTPUT_DIR/$sample_name"
    mkdir -p $sample_output_dir

    # Run HaplotypeCaller
    echo "Processing sample: $sample_name"
    gatk --java-options "-Xmx4G" HaplotypeCaller \
        -R $REFERENCE \
        -I $bam_file \
        -O $sample_output_dir/${sample_name}.g.vcf.gz \
        -ERC GVCF

    if [ $? -eq 0 ]; then
        echo "HaplotypeCaller completed for $sample_name"
    else
        echo "Error running HaplotypeCaller for $sample_name"
    fi
done

echo "HaplotypeCaller finished"
