#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -l mem=16G
#$ -pe smp 2
#$ -N scWGS_markdup

set -euo pipefail

module purge
module load picard-tools
module load samtools

WORKDIR="/path/to/project"

INPUT_DIR="${WORKDIR}/bam_hg38"
OUTPUT_DIR="${WORKDIR}/dup_marked"

JAVA_HEAP="12g"

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "ERROR: Input directory does not exist: $INPUT_DIR"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

shopt -s nullglob

BAMS=(
    "$INPUT_DIR"/*.hg38.sorted.bam
)

shopt -u nullglob

if [[ ${#BAMS[@]} -eq 0 ]]; then
    echo "ERROR: No BAM files found in $INPUT_DIR"
    exit 1
fi

for BAM in "${BAMS[@]}"; do

    BASE=$(basename "$BAM" ".hg38.sorted.bam")

    OUT="${OUTPUT_DIR}/${BASE}.hg38.sorted.markdup.bam"
    METRICS="${OUTPUT_DIR}/${BASE}.dup_metrics.txt"

    if [[ -s "$OUT" && -s "${OUT}.bai" ]]; then
        echo "Skipping $BASE: output already exists."
        continue
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Marking duplicates: $BASE"

    picard \
        -Xmx"$JAVA_HEAP" \
        MarkDuplicates \
        I="$BAM" \
        O="$OUT" \
        M="$METRICS" \
        VALIDATION_STRINGENCY=SILENT

    samtools index \
        -@ 2 \
        "$OUT"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $BASE"

done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Duplicate marking complete."
