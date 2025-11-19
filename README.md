Scripts used in the analysis:

1. fastqc.slurm: Performs FastQC analysis on FastQ files

2. fastp.slurm: Does FastP on FastQ files. Takes into account both mates (reverse and forward, expects mates to be named *_1.fastq.gz and *_2.fastq.gz respectively).

3. fastqc_clean.slurm: Performs FastQC on FastQ files trimmed with FastP, to ensure trimming was successful.

4. multiqc.slurm: Generates a summary MultiQC report based on existing FastQC files.

5. hisat2_index.slurm: Creates index files based on a reference genome for hisat2.

6. hisat2_mapping.slurm: - Maps FastQ files to reference genome
                         - Converts SAM to BAM and sorts these BAM files
                         - Removes temporary SAM files
                         - Indexes the sorted BAMs (creating .bam.bai files)


7. mapping_report.slurm: Using MultiQC, creates a summary report on the mapping results.