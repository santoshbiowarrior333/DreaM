#!/bin/bash
#SBATCH --job-name=mapping_paired
#SBATCH --output=mapping_paired.log
#SBATCH --cpus-per-task=32
#SBATCH --ntasks=1

module load BOWTIE2

# Variables
reference_genome="/mnt/beegfs/esashi/Santosh/pipeline/reference_genome/bowtie2_chm13/chm13v2.0"
threads=32
output_dir="sam"

# Create an output directory if it doesn't exist
mkdir -p $output_dir

# Function to run Bowtie2 on a pair of FASTQ files
run_bowtie2() {
    fastq1=$1
    fastq2=$2
    output_sam="${output_dir}/$(basename $fastq1 _trimmed.fastq).sam"

    echo "Running Bowtie2 for: $fastq1 and $fastq2"
    bowtie2 --end-to-end --very-sensitive -p $threads -x $reference_genome -1 $fastq1 -2 $fastq2 -S $output_sam
    echo "Output SAM file: $output_sam"
}

# Find all _1_ paired trimmed FASTQ files in the current directory
fastq_files=(*_1_*_paired_trimmed.fastq)

# Process all pairs
for fastq1 in "${fastq_files[@]}"; do
    if [[ $fastq1 =~ ^(.*)_1_([^_]+)_paired_trimmed\.fastq$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        suffix="${BASH_REMATCH[2]}"
        fastq2="${prefix}_2_${suffix}_paired_trimmed.fastq"

        if [[ -f $fastq2 ]]; then
            run_bowtie2 "$fastq1" "$fastq2"
        else
            echo "Paired file for $fastq1 not found, skipping..."
        fi
    fi
done

echo "All samples processed. Output SAM files are in $output_dir"
