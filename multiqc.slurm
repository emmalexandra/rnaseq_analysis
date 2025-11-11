#!/usr/bin/env bash

#SBATCH --job-name=multiqc
#SBATCH --cpus-per-task=1
#SBATCH --mem=1000
#SBATCH --time=0:30:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_analysis/MultiQC/MultiQC_out/output_%x_%j.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_analysis/MultiQC/MultiQC_err/error_%x_%j.o
#SBATCH --mail-user=emma.jakobsson@students.unibe.ch
#SBATCH --mail-type=begin,end,fail

# Defining paths
CONTAINER=/containers/apptainer/multiqc-1.19.sif
INPUT_DIR=/data/users/ejakobsson/rnaseq_analysis/FastQC
OUTPUT_DIR=/data/users/ejakobsson/rnaseq_analysis/MultiQC

# Creating directories (-p: if they exist, ignore)
mkdir -p "$OUTPUT_DIR/MultiQC_out"
mkdir -p "$OUTPUT_DIR/MultiQC_err"
mkdir -p "$OUTPUT_DIR"

echo "Running MultiQC on $(pwd)"

# Binding the whole project folder so the container can access FastQC results for MultiQC processing
apptainer exec --bind /data/users/ejakobsson/rnaseq_analysis \
    "$CONTAINER" multiqc "$INPUT_DIR" -o "$OUTPUT_DIR"

echo "MultiQC report is finished!"