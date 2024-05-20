# Approach-for-mapping in Centromere
This provides the pipeline for analysis of short reads and mapping to repeated regions such as HOR in centromere.
Deduplication of Reads to enhance accurate Mapping of short-reads in centromere (DreaM).
DreaM: A universal customized computational pipeline for improved resolution of DNA-protein interaction in centromeres.
	The approach involves the usage of a fundamental AWK-based approach for deduplication of reads from the FASTQ file before trimming.
	Next step, adaptor contamination is removed by using standard trimming algorithms
	Mapping is performed with specifics where N/n=0 serves for no-mismatch allowance.
	Uniquely mapped reads are directly obtained by the removal of F2308.
	pygenometracks were used to visualize the robustness of the approach.

 The pipeline for sequence analysis and associated files are as follows:

1. DreaM.awk: This script can be used to deduplicate the FASTQ reads (It treats the reads as seperate and not as paired end).
   Note: For deduplication, run this script in the terminal as follows (for file in *.fastq; do awk -f ./DreaM.awk “$file”;done)
	This script will process all the FASTQ reads in the current folder and split the duplicated and deduplicated reads.
Optional:
2. Sync_DreaM.awk: Next, step if you are processing paired-end reads, This script must be run for each reads as followed
   	awk -f ./Sync_DreaM.awk “$file_R1_dedup.fastq” “$file_R2_dedup.fastq”;done
   	Where, R1 and R2 are two reads from paired end processed by DreaM.awk (resulting in these two deduplicated version).
3. 
