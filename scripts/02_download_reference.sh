#!/bin/bash

output_dir="/mnt/hdd_b/home/user02/reference/hg38/"

mkdir -p "$output_dir"

#Mills and 1000G Gold Standard INDELs
wget -P "$output_dir" https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
wget -P "$output_dir" https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz.tbi

#HapMap
wget -P "$output_dir" https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz
wget -P "$output_dir" https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz.tbi


echo "Downloads completed. Files are saved in $output_dir"
