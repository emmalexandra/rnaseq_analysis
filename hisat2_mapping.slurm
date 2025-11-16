#!/usr/bin/env bash

#SBATCH --job-name=hisat2_mapping
#SBATCH --array=8-14             # Running a few pairs at a time
#SBATCH --cpus-per-task=4
#SBATCH --mem=8000M
#SBATCH --time=3:00:00
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/ejakobsson/rnaseq_analysis/Mapped_files/Mapped_out/output_%x_%A_%a.o
#SBATCH --error=/data/users/ejakobsson/rnaseq_analysis/Mapped_files/Mapped_err/error_%x_%A_%a.o

# Specifying location of working directory, container, index files, and cleaned fastq files, and where output should go
WORKDIR=/data/users/ejakobsson/rnaseq_analysis
CONTAINER=/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif
INDEX_DIR=$WORKDIR/Index_files
INPUT_DIR=$WORKDIR/FastP
OUTPUT_DIR=$WORKDIR/Mapped_files

mkdir -p "$OUTPUT_DIR"
mkdir -p $WORKDIR/Mapped_files/Mapped_out
mkdir -p $WORKDIR/Mapped_files/Mapped_err

# Specifying all R1 (-> forward) and R2 reads
R1_FILES=(${INPUT_DIR}/*_1_clean.fastq.gz)
R2_FILES=(${INPUT_DIR}/*_2_clean.fastq.gz)

# Selecting pair to run + keeping the original name
R1=${R1_FILES[$SLURM_ARRAY_TASK_ID]}
R2=${R2_FILES[$SLURM_ARRAY_TASK_ID]}
SAMPLE=$(basename "$R1" _1_clean.fastq.gz)

echo "Processing sample: $SAMPLE"

# -x: The basename of the index for the reference genome.
# -1 & -2: Tells hisat2 which files (reads) belong together, as specified above.
# -S: File to write SAM alignments to (specifying output directory).
# rna-strandedness for RF
apptainer exec --bind /data "$CONTAINER" \
    hisat2 -p $SLURM_CPUS_PER_TASK \
    -x ${INDEX_DIR}/hisat2_index \
    -1 "$R1" -2 "$R2" \
    --rna-strandness RF \
    -S ${OUTPUT_DIR}/${SAMPLE}.sam

echo "Finished mapping for $SAMPLE"