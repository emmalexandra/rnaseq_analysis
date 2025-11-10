#!/usr/bin/env bash

#SBATCH --job-name=multiqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=1000
#SBATCH --time=0:30:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_course_analysis/MultiQC/MultiQC_out/output_%x_%j.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_course_analysis/MultiQC/MultiQC_err/error_%x_%j.o
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=begin,end,fail

# defining paths to container, input, and output folders
CONTAINER=/data/containers/apptainer/multiqc-1.19.sif
INPUT_DIR=/data/users/ejakobsson/rnaseq_analysis/FastQC
OUTPUT_DIR=/data/users/ejakobsson/rnaseq_analysis/MultiQC

# creating needed directories
mkdir -p "$OUTPUT_DIR/MultiQC_out"
mkdir -p "$OUTPUT_DIR/MultiQC_err"

# move to folder with FastQC files needed for input
cd "$INPUT_DIR"

echo "Running MultiQC on $(pwd)"

# running MultiQC via Apptainer
apptainer exec --bind /data/users/ejakobsson/rnaseq_analysis,"$CONTAINER" \
    multiqc . -o "$OUTPUT_DIR"

echo "MultiQC report is finished!"