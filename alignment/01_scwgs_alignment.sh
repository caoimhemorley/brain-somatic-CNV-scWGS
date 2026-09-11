#!/bin/bash -l

#$ -l h_rt=04:00:00
#$ -l mem=24G
#$ -pe smp 16
#$ -N scWGS_alignment

set -euo pipefail

module purge
module load bwa
module load samtools

THREADS=16
SORT_THREADS=8

WORKDIR="/path/to/trimmed_fastq"
REFERENCE="/path/to/reference/human_GRCh38_no_alt_analysis_set.fasta"
OUTDIR="${WORKDIR}/bam_hg38"

if [[ ! -d "$WORKDIR" ]]; then
    echo "ERROR: WORKDIR does not exist: $WORKDIR"
    exit 1
fi

if [[ ! -f "$REFERENCE" ]]; then
    echo "ERROR: Reference genome not found: $REFERENCE"
    exit 1
fi

mkdir -p "$OUTDIR"

shopt -s nullglob

R1_FILES=(
    "$WORKDIR"/*_R1_val_1_val_1.fq.gz
    "$WORKDIR"/*_R1_001_val_1_val_1.fq.gz
)

shopt -u nullglob

if [[ ${#R1_FILES[@]} -eq 0 ]]; then
    echo "ERROR: No matching R1 FASTQ files found."
    exit 1
fi

for r1 in "${R1_FILES[@]}"; do

    filename=$(basename "$r1")

    if [[ "$filename" == *_R1_001_val_1_val_1.fq.gz ]]; then
        r2="${r1/_R1_001_val_1_val_1.fq.gz/_R2_001_val_2_val_2.fq.gz}"
        base="${filename%_R1_001_val_1_val_1.fq.gz}"

    elif [[ "$filename" == *_R1_val_1_val_1.fq.gz ]]; then
        r2="${r1/_R1_val_1_val_1.fq.gz/_R2_val_2_val_2.fq.gz}"
        base="${filename%_R1_val_1_val_1.fq.gz}"

    else
        echo "Skipping unrecognised filename: $filename"
        continue
    fi

    if [[ ! -f "$r2" ]]; then
        echo "ERROR: Missing R2 for $filename"
        echo "Expected: $r2"
        continue
    fi

    out="${OUTDIR}/${base}.hg38.sorted.bam"

    if [[ -s "$out" ]]; then
        echo "Skipping $base: BAM already exists."
        continue
    fi

    echo "Aligning: $base"

    bwa mem \
        -t "$THREADS" \
        -R "@RG\tID:${base}\tSM:${base}\tLB:lib1\tPL:ILLUMINA\tPU:${base}" \
        "$REFERENCE" \
        "$r1" \
        "$r2" |
    samtools sort \
        -@ "$SORT_THREADS" \
        -o "$out"

    samtools index \
        -@ "$SORT_THREADS" \
        "$out"

    echo "Completed: $base"

done

echo "Alignment complete."
