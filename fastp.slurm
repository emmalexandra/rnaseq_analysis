#!/usr/bin/env bash

#SBATCH --job-name=fastp
#SBATCH --array=0-14			# 15 pairs that should be processed together!
#SBATCH --cpus-per-task=2
#SBATCH --mem=2000M
#SBATCH --time=2:00:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_analysis/FastQC_clean/FastQC_clean_out/output_%x_%A_%a.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_analysis/FastQC_clean/FastQC_clean_err/error_%x_%A_%a.o

# Defining paths
WORKDIR=/data/users/ejakobsson/rnaseq_analysis
CONTAINER=/containers/apptainer/fastp_0.24.1.sif
INPUT_DIR=$WORKDIR/reads_Bloods
OUTPUT_DIR=$WORKDIR/FastP

# Creating directories for output
mkdir -p $WORKDIR/FastP/FastP_out
mkdir -p $WORKDIR/FastP/FastP_err
mkdir -p "$OUTPUT_DIR"

# Nb! FastQ data is paired end (gzip compressed)! 
# -> must tell FastP to process the pairs (read 1 & 2) in the same manner
R1_FILES=(${INPUT_DIR}/*_1.fastq.gz)

# Selecting file
R1_FILE=${R1_FILES[$SLURM_ARRAY_TASK_ID]}
R2_FILE=${R1_FILE/_1.fastq.gz/_2.fastq.gz}

# Sample name (everything before _1.fastq.gz)
SAMPLE=$(basename "$R1_FILE" _1.fastq.gz)

# Checking that both reads are processed
echo "Processing sample: $SAMPLE"
echo "R1: $R1_FILE"
echo "R2: $R2_FILE"

# Using following tool: fastp_0.24.1.sif
# Need to bind both the input and output directories (symbolic link to reads_Blood)
# Processing both reads (-i, -o and -I, -O)
# Creating .json & .html reports
# Auto-detection of adapters disabled for paired end data by default: turning it on

apptainer exec \
  --bind $WORKDIR/reads_Blood:"$INPUT_DIR" \
  --bind $WORKDIR/FastP:"$OUTPUT_DIR" \
  "$CONTAINER" \
  fastp -i "$R1_FILE" \
        -I "$R2_FILE" \
        -o "$OUTPUT_DIR/${SAMPLE}_1_clean.fastq.gz" \
        -O "$OUTPUT_DIR/${SAMPLE}_2_clean.fastq.gz" \
        -j "$OUTPUT_DIR/${SAMPLE}.json" \
        -h "$OUTPUT_DIR/${SAMPLE}.html" \
        -w $SLURM_CPUS_PER_TASK \
        --detect_adapter_for_pe

echo "Finished sample: $SAMPLE (R1: $R1_FILE, R2: $R2_FILE)"

# Link to FastP README for more options: https://github.com/OpenGene/fastp/blob/master/README.md#simple-usage
