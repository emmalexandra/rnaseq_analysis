#!/usr/bin/env bash

#SBATCH --job-name=hisat2_index
#SBATCH --cpus-per-task=3
#SBATCH --mem=8000M
#SBATCH --time=3:00:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_analysis/Index_files/Index_out/output_%x_%A_%a.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_analysis/Index_files/Index_err/error_%x_%A_%a.o

# Specifying location of working directory, container, index files, and cleaned fastq files, and where output should go
WORKDIR=/data/users/ejakobsson/rnaseq_analysis
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif
REF_DIR=$WORKDIR/reference_genome
OUTPUT_DIR=$WORKDIR/Index_files

mkdir -p "$OUTPUT_DIR"
mkdir -p $WORKDIR/Index_files/Index_out
mkdir -p $WORKDIR/Index_files/Index_err

# Defining reference genome sequence for indexing
REF_FASTA=${REF_DIR}/Mus_musculus.GRCm39.dna.primary_assembly.fa

# Creating index files
# -p: number of parallel search threads (-> faster). Specified that hisat2 should use CPUs allocated to SLURM, without oversubscribing
apptainer exec --bind /data "$CONTAINER" \
    hisat2-build -p $SLURM_CPUS_PER_TASK "$REF_FASTA" "${OUTPUT_DIR}/hisat2_index"s