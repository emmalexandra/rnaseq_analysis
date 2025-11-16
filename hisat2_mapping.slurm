#!/usr/bin/env bash

#SBATCH --job-name=hisat2_mapping
#SBATCH --array=10-14             # Running a few pairs at a time (0-4, 5-9, 10-14)
#SBATCH --cpus-per-task=4
#SBATCH --mem=25000M
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

# Specifying all R1 (-> forward) and R2 (reverse) reads
R1_FILES=(${INPUT_DIR}/*_1_clean.fastq.gz)
R2_FILES=(${INPUT_DIR}/*_2_clean.fastq.gz)

# Selecting pair to run + keeping the original name
R1=${R1_FILES[$SLURM_ARRAY_TASK_ID]}
R2=${R2_FILES[$SLURM_ARRAY_TASK_ID]}
SAMPLE=$(basename "$R1" _1_clean.fastq.gz)

echo "Processing sample: $SAMPLE"

# Saving SAMs only temporarily on scratch to save space
SCRATCH_SAM=$SCRATCH/${SAMPLE}.sam

# Final sorted BAM
FINAL_BAM_SORTED=${OUTPUT_DIR}/${SAMPLE}_sorted.bam

# Also creating summary files that can later be used by multiqc
SUMMARY_FILE=${OUTPUT_DIR}/${SAMPLE}_hisat2_summary.txt

# Mapping
#   -x: The basename of the index for the reference genome.
#   -1 & -2: Tells hisat2 which files (reads) belong together, as specified above.
#   -S: File to write SAM alignments to
#   rna-strandedness for RF
apptainer exec --bind /data "$CONTAINER" \
    hisat2 -p $SLURM_CPUS_PER_TASK \
    -x ${INDEX_DIR}/hisat2_index \
    -1 "$R1" -2 "$R2" \
    --rna-strandness RF \
    --summary-file "$SUMMARY_FILE" \
    -S "$SCRATCH_SAM"

echo "Finished mapping for $SAMPLE, next converting to BAM..."

# SAM -> BAM + sorting
# If sort input is SAM, it is automatically converted to BAM
apptainer exec --bind /data "$CONTAINER" \
    samtools sort -@ $SLURM_CPUS_PER_TASK -o "$FINAL_BAM_SORTED" "$SCRATCH_SAM"

echo "BAM sorted and written to $FINAL_BAM_SORTED"

# Removing SAM file
rm -f "$SCRATCH_SAM"

echo "Temporary SAM removed."


# BAM indexing (creates .bam.bai)
apptainer exec --bind /data "$CONTAINER" \
    samtools index "$FINAL_BAM_SORTED"

echo "Sorted BAM indexed."