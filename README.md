# Approach-for-mapping in HOR 
This provides the pipeline for analysis of short-reads and mapping to repeated regions such as HOR in centromere
Deduplication of Reads to enhance accurate Mapping of short-reads in centromere (DreaM)
DreaM: A universal customized computational pipeline for improved resolution of DNA-protein interaction in centromeres
	The approach involves the usage of a fundamental AWK-based approach for deduplication of reads from the FASTQ file before trimming.
	Next step, adaptor contamination is removed by using standard trimming algorithms
	Mapping is performed with specifics where N/n=0 serves for no-mismatch allowance.
	Uniquely mapped reads are directly obtained by the removal of F2308.
	pygenometracks were used to visualize the robustness of the approach.
