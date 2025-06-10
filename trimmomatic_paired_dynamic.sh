#!/bin/bash
#SBATCH --job-name=trimmomatic_paired_job
#SBATCH --output=trimmomatic_paired_job.out
#SBATCH --error=trimmomatic_paired_job.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16

# Load necessary modules
module load TRIMMOMATIC
module load JAVA

# Define the adapter file path
ADAPTERS="/mnt/beegfs/esashi/Santosh/pipeline/xanita/reanalysis/all_adaptors.fa"

# Function to process paired-end files with Trimmomatic
process_paired_end() {
  local file1=$1
  local file2=$2
  local base1=$(basename "$file1" .fastq)
  local base2=$(basename "$file2" .fastq)

  echo "Processing $file1 and $file2 with Trimmomatic"

  trimmomatic PE -threads 16 -phred33 "$file1" "$file2" \
    "${base1}_paired_trimmed.fastq" "${base1}_unpaired.fastq" \
    "${base2}_paired_trimmed.fastq" "${base2}_unpaired.fastq" \
    ILLUMINACLIP:$ADAPTERS:2:30:10 \
    CROP:145 HEADCROP:13 \
    LEADING:5 TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:90

  echo "Completed processing $file1 and $file2"
}

# Find and process paired files, avoiding already processed files
for file1 in *_1*.fastq; do
  # Determine the corresponding file2
  file2=${file1/_1/_2}

  # Base names for output files
  base1=$(basename "$file1" .fastq)
  base2=$(basename "$file2" .fastq)

  # Check if any output files already exist
  if [[ -f "${base1}_paired_trimmed.fastq" ]] || [[ -f "${base1}_unpaired.fastq" ]] || \
     [[ -f "${base2}_paired_trimmed.fastq" ]] || [[ -f "${base2}_unpaired.fastq" ]]; then
    echo "Skipping already processed pair: $file1 and $file2"
    continue
  fi

  if [[ -f "$file2" ]]; then
    echo "Found pair: $file1 and $file2"
    process_paired_end "$file1" "$file2"
  else
    echo "Pair for $file1 not found. Skipping."
  fi
done
