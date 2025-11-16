#!/usr/bin/env bash

#SBATCH --job-name=mapping_report_multiqc 
#SBATCH --cpus-per-task=1
#SBATCH --mem=4000M
#SBATCH --time=0:30:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_analysis/MultiQC_mapping/multiqc_out.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_analysis/MultiQC_mapping/multiqc_err.e

# Defining work directory and paths
WORKDIR=/data/users/ejakobsson/rnaseq_analysis
CONTAINER=/containers/apptainer/multiqc-1.19.sif
INPUT_DIR="$WORKDIR"/Mapped_files
OUTPUT_DIR="$WORKDIR"/MultiQC_mapping

mkdir -p "$OUTPUT_DIR"

echo "Running MultiQC on hisat2 summary files for mapping..."

# Running multiqc on summary reports
apptainer exec --bind "$WORKDIR" "$CONTAINER" \
    multiqc "$INPUT_DIR" -o "$OUTPUT_DIR"

echo "MultiQC report $OUTPUT_DIR/multiqc_report.html generated."