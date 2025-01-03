#!/bin/bash

#SBATCH --job-name=analysis_pipeline
#SBATCH --output=analysis.log
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --time=120:00:00

module load BOWTIE2
module load SAMTOOLS
module load DEEPTOOLS
module load BEDOPS
module load BEDTOOLS

for file in *.sam; do
    samtools view -bS "$file" -o "${file%.sam}.bam"
done

for file in *.bam; do
    fixmate_file="${file%.bam}_fixmate.bam"
    samtools fixmate -m "$file" "$fixmate_file"
done

for file in *_fixmate.bam; do
    samtools sort "${file}" -o "${file%.*}_sorted.bam"
done

for file in *_sorted.bam; do
    samtools markdup -r "$file" "${file/_fixmate_sorted.bam/.nodup.sorted.bam}"
done

for file in *.nodup.sorted.bam; do
    samtools view -bu -F 2308 "$file" -o "${file%.nodup.sorted.bam}_unique_mapped.bam"
done

for file in *_unique_mapped.bam; do
    samtools index "$file"
done

for FILE in *_unique_mapped.bam; do
    echo "Processing file: $FILE"
    bamCoverage -b "$FILE" -o "${FILE%._unique_mapped.bam}.bw" --normalizeUsing RPKM --verbose
    echo ""
done

exit
