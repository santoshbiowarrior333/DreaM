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
	This script will process all the FASTQ reads in the current folder and split the duplicated and deduplicated reads as $file_1_DreaM.fastq/$file_2_DreaM.fastq for both the pairs if exist, if the reads are single then it will produce only one file; $file_DreaM.fastq.
Optional:
2. Sync_DreaM.sh: Next, step if you are processing paired-end reads, This script must be run for the folder containing the reads deduplicated in previous step.
   	At this step, code equals the reads in both the output so that it can be processed through trimming softwares. Code "sbatch Sync_DreaM.sh" can be used to run this script, output will be $SYNCED_FILE, $SYNCED_PAIR_FILE.
   	Where, R1 and R2 are two reads from paired end processed by DreaM.awk (resulting in these two deduplicated version).
3. In the next step, these paired end/ single-end reads can be trimmed with help of Trimmomatic:
   Refer paired trimming files and single-end/paired-end mapping provided as "$files.sh" for further processing and obtaining the bigwig files using "post_mapping_processing.sh" which will retain only unique alignments and genrate bigwig files that can be visualized directly in the IGV. These files consider T2T assembly and its index for mapping. All the *.sh files can be executed as "sbatch file.sh".

***Note: These codes must be edited for the resources that are available at the user-end such as number of cores, loading of modules could be different. Also, every line of code can be edited according to the naming convention of user files.

For any query: please reach to path1327@ox.ac.uk. The code related to the figure generation has not been provided here. It is available upon request.
