#!/bin/bash

# SAMPLE RANGE
start=149
end=178

output_file="/mnt/hdd_b/home/user02/sample_map.txt"

> "$output_file"

for i in $(seq -f "%03g" $start $end); do
  sample_name="HG00$i"

  # Find the folder matching the sample pattern
  folder_path=$(find /mnt/hdd_b/home/user02/output/ -type d -name "${sample_name}.chrom11.ILLUMINA.bwa.*" | head -n 1)

  if [ -z "$folder_path" ]; then
    echo "No folder found for $sample_name"
  else
    echo "Folder found for $sample_name: $folder_path"

    # Look for the .g.vcf.gz file dynamically within the folder
    gvcf_file=$(find "$folder_path" -type f -name "*.g.vcf.gz" | head -n 1)

    if [ -z "$gvcf_file" ]; then
      echo "gVCF file not found for $sample_name in $folder_path"
    else
      # Write to the sample map file
      echo "$sample_name\t$gvcf_file" >> "$output_file"
    fi
  fi
done

echo "sample_map.txt has been created at $output_file"
