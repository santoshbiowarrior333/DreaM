#!/bin/bash
#SBATCH --job-name=mapping_single
#SBATCH --output=mapping_single.log
#SBATCH --cpus-per-task=32
#SBATCH --ntasks=1

module load BOWTIE2

# Variables
reference_genome="/mnt/beegfs/esashi/Santosh/pipeline/reference_genome/bowtie2_chm13/chm13v2.0"
threads=32
output_dir="sam_single"  # Changed output directory name to "sam_single"

# Create an output directory if it doesn't exist
mkdir -p $output_dir

# Function to run Bowtie2 on a single FASTQ file
run_bowtie2() {
    fastq=$1
    output_sam="${output_dir}/$(basename $fastq _trimmed.fastq).sam"

    echo "Running Bowtie2 for: $fastq"
    bowtie2 --end-to-end --very-sensitive -p $threads -x $reference_genome -U $fastq -S $output_sam
    echo "Output SAM file: $output_sam"
}

# Find all single-end trimmed FASTQ files in the current directory
fastq_files=(*_single_trimmed.fastq)

# Process all single-end FASTQ files
for fastq in "${fastq_files[@]}"; do
    run_bowtie2 "$fastq"
done

echo "All samples processed. Output SAM files are in $output_dir"
