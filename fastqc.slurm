#!/usr/bin/env bash

#SBATCH --job-name=fastqc
#SBATCH --array=0-29			# Which files should be processed?
#SBATCH --cpus-per-task=1
#SBATCH --mem=1000M
#SBATCH --time=1:00:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_analysis/FastQC/FastQC_out/output_%x_%A_%a.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_analysis/FastQC/FastQC_err/error_%x_%A_%a.o

# Defining working directory, container path and where input is and output should be saved
WORKDIR=/data/users/ejakobsson/rnaseq_analysis
CONTAINER=/containers/apptainer/fastqc-0.12.1.sif
INPUT_DIR=$WORKDIR/reads_Blood
OUTPUT_DIR=$WORKDIR/FastQC

mkdir -p $WORKDIR/FastQC/FastQC_out
mkdir -p $WORKDIR/FastQC/FastQC_err
mkdir -p "$OUTPUT_DIR"

# Creating an array of all FASTQ files
FILES=($INPUT_DIR/*.fastq.gz)

# Selecting files we want to process
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

echo "Processing $FILE"

# Need to use bind, otherwise apptainer module cannot be found
apptainer exec --bind $WORKDIR$ "$CONTAINER" \
    fastqc -t $SLURM_CPUS_PER_TASK -o "$OUTPUT_DIR" "$FILE"

echo "Finished $FILE"
