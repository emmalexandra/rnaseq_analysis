#!/usr/bin/env bash

#SBATCH --job-name=featureCounts
#SBATCH --cpus-per-task=4
#SBATCH --mem=4000M
#SBATCH --time=2:00:00
#SBATCH --partition=pibu_el8

# Specifying working directory, container, input and output directories
WORKDIR=/data/users/ejakobsson/rnaseq_analysis
CONTAINER=/containers/apptainer/subread_2.0.6.sif
ANNOTATION_DIR=$WORKDIR/reference_genome
INPUT_DIR=$WORKDIR/Mapped_files
OUTPUT_DIR=$WORKDIR/FeatureCounts

mkdir -p "$OUTPUT_DIR"

# Running FeatureCounts
# Perform strand-specific read counting: '-s 2' for reversely stranded
# -p: paired-end
apptainer exec --bind $WORKDIR "$CONTAINER" \
    featureCounts -T $SLURM_CPUS_PER_TASK \
    -a "$ANNOTATION_DIR/Mus_musculus.GRCm39.115.gtf" \
    -o "$OUTPUT_DIR/counts.txt" \
    -s 2 \
    -p \
    "$INPUT_DIR"/*_sorted.bam

echo "Finished FeatureCounts."