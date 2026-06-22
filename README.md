# GATK Germline Short Variant Discovery — Chromosome 11

**Bioinformatics 2024-25 · NKUA DSIT MSc · Vasileios-Klearchhos Chatzitolios**

## Overview

This project implements the [GATK Best Practices](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932) germline short variant discovery workflow (SNPs + INDELs) on chromosome 11 exome sequencing data from 15 individuals drawn from the 1000 Genomes Project. Starting from GRCh37-aligned BAM files, the pipeline realigns reads to GRCh38, processes them through duplicate marking and base quality score recalibration (BQSR), calls variants per sample using HaplotypeCaller in GVCF mode, performs joint genotyping across all 15 samples, and filters the resulting callset with Variant Quality Score Recalibration (VQSR). Statistical summaries and distribution plots are generated from the final filtered VCF.

## Dataset

| Property | Value |
|----------|-------|
| Source | 1000 Genomes Project phase 3 (EBI FTP) |
| Samples | 15 individuals — GBR and FIN populations |
| Sample IDs | HG00149, HG00150, HG00151, HG00154, HG00155, HG00157, HG00158, HG00159, HG00160, HG00171, HG00173, HG00174, HG00176, HG00177, HG00178 |
| Target region | Chromosome 11 (exome capture) |
| Raw data size | ~7.28 GB |
| Starting reference | GRCh37/hg19 (source BAMs) → realigned to **GRCh38/hg38** |

## Pipeline

```
chr11 BAMs (GRCh37-aligned, from 1000 Genomes)
        │
        ▼
1.  BAM → FASTQ              samtools fastq
        │
        ▼
2.  Alignment to GRCh38      BWA-MEM (-t 4, hg38 chr11 index)
        │
        ▼
3.  Sort & Index              samtools sort / index → *_sorted.bam
        │
        ▼
4.  Add Read Groups           Picard AddOrReplaceReadGroups
        │
        ▼
5.  Mark Duplicates           GATK MarkDuplicates → *_marked_duplicates.bam
        │
        ▼
6.  BQSR                      GATK BaseRecalibrator → ApplyBQSR → *_recalibrated.bam
        │
        ▼
7.  Variant Calling           GATK HaplotypeCaller -ERC GVCF  (per sample)
        │
        ▼
8.  Consolidate               GATK GenomicsDBImport (--intervals chr11, --batch-size 50)
        │
        ▼
9.  Joint Genotyping          GATK GenotypeGVCFs → chr11_joint.vcf.gz
        │
        ▼
10. Validate                  GATK ValidateVariants
        │
        ▼
11. Filter SNPs               GATK VariantRecalibrator (-mode SNP) → ApplyVQSR
12. Filter INDELs             GATK VariantRecalibrator (-mode INDEL) → ApplyVQSR
        │
        ▼
    chr11_joint_filtered_strict.vcf.gz
        │
        ▼
13. Statistics                bcftools stats / query, GATK VariantsToTable
14. Visualisation             Python / Jupyter (notebooks/bioinfoplotting.ipynb)
```

## Tools and Versions

| Tool | Version | Role |
|------|---------|------|
| GATK | 4.6.1.0 | Variant calling, duplicate marking, BQSR, VQSR, joint genotyping |
| BWA | — | Short-read alignment to GRCh38 |
| SAMtools | — | BAM manipulation, sorting, indexing, FASTQ conversion |
| Picard | 3.3.0 (bundled with GATK) | Read group addition |
| BCFtools | 1.19 | VCF statistics and field extraction |
| Python + Jupyter | — | Statistical analysis and visualisation |

**Reference and resource files (downloaded, not included in this repository):**

| Resource | Source |
|----------|--------|
| GRCh38/hg38 reference (hg38.fa) | Broad Institute GCS |
| Mills and 1000G gold standard INDELs (hg38) | Broad Institute GCS |
| HapMap 3.3 (hg38) | Broad Institute GCS |
| 1000G Omni 2.5 (hg38) | Broad Institute GCS |
| 1000G phase 1 high-confidence SNPs (hg38) | Broad Institute GCS |

## Repository Structure

```
.
├── scripts/                        # Pipeline scripts (numbered in execution order)
│   ├── 01_download_data.sh         # Download chr11 BAMs from 1000 Genomes EBI FTP
│   ├── 02_download_reference.sh    # Download hg38 GATK resource VCFs from Broad GCS
│   ├── 03_realign_data.sh          # BAM → FASTQ → BWA alignment → sorted BAM
│   ├── 04_duplicates_bqsr.sh       # Add read groups, mark duplicates, run BQSR
│   ├── 05_haplo.sh                 # Per-sample HaplotypeCaller in GVCF mode
│   └── 06_create_sample_map.sh     # Build sample_map.txt for GenomicsDBImport
│
├── results/
│   ├── stats/
│   │   ├── HG00149_stats.txt       # Per-sample GVCF statistics (example sample)
│   │   ├── raw_stats.txt           # Pre-VQSR joint callset stats (bcftools stats)
│   │   └── filtered_stats.txt      # Post-VQSR stats (bcftools stats)
│   ├── tables/
│   │   ├── allele_frequencies.txt  # Per-variant allele frequency (AF tag)
│   │   ├── depth.txt               # Per-variant sequencing depth (INFO/DP)
│   │   ├── quality_scores.txt      # Per-variant quality scores (QUAL)
│   │   └── indels_table.txt        # INDEL records (CHROM/POS/REF/ALT/TYPE)
│   └── plots/
│       ├── allele_freq.png         # Allele frequency distribution
│       ├── QualityScore.png        # Quality score distribution
│       └── depth.png               # Depth of coverage distribution
│
├── notebooks/
│   └── bioinfoplotting.ipynb       # Statistical analysis and plot generation
│
├── logs/                           # Terminal session captures (script utility)
│   ├── pipeline.txt                # GenomicsDBImport + GenotypeGVCFs run log
│   ├── statistics.txt              # VQSR, ValidateVariants, bcftools analysis log
│   └── download_data.txt           # Data download log
│
├── sample_map.txt                  # Sample name → GVCF path mapping (15 samples)
├── Biotechnology_Chatzitolios.pdf  # Full written report
└── .gitignore
```

## Scripts

| Script | Purpose | Key inputs | Key outputs |
|--------|---------|-----------|-------------|
| `01_download_data.sh` | Download chr11 BAM + BAI for each sample (loops HG00149–HG00178) | EBI FTP | `data/HG00XXX/exome_alignment/*.bam/.bai` |
| `02_download_reference.sh` | Download GATK resource VCFs (Mills INDELs, HapMap) | Broad GCS | `reference/hg38/` VCFs + TBIs |
| `03_realign_data.sh` | Convert GRCh37 BAMs to FASTQ; align to hg38 chr11; sort and index | GRCh37 BAMs, chr11 `.fa` | `*_sorted.bam`, `*_sorted.bam.bai` |
| `04_duplicates_bqsr.sh` | Add read groups; mark duplicates; apply BQSR | `*_sorted.bam`, known-sites VCFs | `*_recalibrated.bam` |
| `05_haplo.sh` | Run HaplotypeCaller in GVCF mode on each recalibrated BAM | `*_recalibrated.bam`, chr11 ref | `*.g.vcf.gz` per sample |
| `06_create_sample_map.sh` | Generate the tab-separated sample name → GVCF path file required by GenomicsDBImport | Output directory tree | `sample_map.txt` |

Steps 7–12 (GenomicsDBImport through ApplyVQSR) were run interactively. The full commands and GATK runtime output are captured in `logs/pipeline.txt` and `logs/statistics.txt`.

## Key Results

| Metric | Value |
|--------|-------|
| Samples | 15 |
| Total variants (chr11) | 73,805 |
| SNPs | 68,528 |
| INDELs | 5,279 |
| Multi-allelic sites | 64 |
| Ti/Tv ratio | 1.72 |
| Insertions | 2,139 |
| Deletions | 2,840 |
| Average indel length | 2.17 bp |
| Mean depth (DP) | 4.77 |
| Median depth | 4.00 |
| Mean QUAL score | 68.76 |

Alignment quality for the example sample HG00149: 98.69% of reads mapped, 95.78% properly paired.

## Reproducibility

Large files required to run the pipeline are excluded from this repository (see `.gitignore`). To reproduce:

1. Download source BAMs: `bash scripts/01_download_data.sh`
2. Download reference resources: `bash scripts/02_download_reference.sh` (also download the hg38 FASTA, Omni, and 1000G SNP VCFs manually from Broad GCS — see `logs/download_data.txt` for the exact commands used)
3. Update hardcoded paths in scripts 03–06 to match your local environment
4. Run scripts in order: `03` → `04` → `05` → `06`
5. Run GenomicsDBImport, GenotypeGVCFs, and VQSR as documented in `logs/pipeline.txt` and `logs/statistics.txt`

Estimated storage: ~15 GB for source BAMs, ~3 GB for reference files, ~5 GB for intermediate BAMs per sample.

## References

1. Van der Auwera GA & O'Connor BD. *Genomics in the Cloud*. O'Reilly Media, 2020.
2. GATK Best Practices: Germline short variant discovery (SNPs + Indels). Broad Institute. https://gatk.broadinstitute.org/hc/en-us/articles/360035535932
3. 1000 Genomes Project Consortium. A global reference for human genetic variation. *Nature* 526, 68–74 (2015).
