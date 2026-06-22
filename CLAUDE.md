# CLAUDE.md

## Project Context

This is a bioinformatics exercise for the **Bioinformatics Course, NKUA DSIT MSc 2024-2025**.
It implements a **GATK germline short variant discovery workflow** (SNPs + Indels) following the
[GATK Best Practices](https://gatk.broadinstitute.org/hc/en-us/articles/360035535932-Germline-short-variant-discovery-SNPs-Indels),
a FASTQ-to-VCF pipeline.

The exercise is being converted into a **portfolio repository** for GitHub. The spec lives in
`Biotechnology_Chatzitolios.pdf`.

## Your Role

Help turn this folder (shell scripts, Python scripts, results, PDF) into a clean, well-structured,
portfolio-quality repo with a README.

## Hard Constraints

- **DO NOT alter, rewrite, or "fix" any code** (`.sh`, `.py`, or otherwise). Code is read-only.
- **DO NOT modify result files** or any pipeline outputs.
- You **may** create new files: `README.md`, `.gitignore`, directory structure, docs.
- You **may** move/rename files to organize the repo — but propose the moves first and wait for
  confirmation before executing.
- If you find something **clearly and seriously wrong** — the kind of error that would stand out to
  anyone giving the code a quick glance (e.g. an obviously wrong reference genome, a flag that
  contradicts the PDF's stated method, a hardcoded path that breaks reproducibility, a step in the
  wrong order vs. GATK best practices) — **flag it to me with file + line, explain why, and stop.
  Do not fix it.** Minor style nits are not worth flagging.

## Working Approach

1. Read `Biotechnology_Chatzitolios.pdf` first to understand the assigned exercise.
2. Inventory the folder: every script, what it does, inputs/outputs, execution order.
3. Map the actual implementation against the PDF spec and GATK best practices.
4. Only then propose repo structure + README.

## Tech Domain

- Standard GATK germline pipeline: BWA alignment → MarkDuplicates → BQSR → HaplotypeCaller →
  joint genotyping → VariantFiltration/VQSR.
- Tools likely involved: BWA, samtools, Picard, GATK4, bcftools.
- Author: Vasilis Chatzitolios.