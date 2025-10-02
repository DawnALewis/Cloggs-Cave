#!/bin/bash

module load Nextflow/21.03.0

INPUT_FILE=/<PathTo>/capture_input.tsv
FASTA=/<PathTo>/Refs/Homo_sapiens/GATK/GRCh37/Sequence/WholeGenomeFasta/human_g1k_v37_decoy.fasta
FASTA_INDEX=/<PathTo>/Refs/Homo_sapiens/GATK/GRCh37/Sequence/WholeGenomeFasta/human_g1k_v37_decoy.fasta.fai
BWA_INDEX=/<PathTo>/Refs/Homo_sapiens/GATK/GRCh37/Sequence/BWAIndex/

nextflow run /<PathTo>/shyrav/resources/eager-v2.4.5-sharding-adna-trim/ -c ./phoenix_local.config \
	-with-singularity \
	-profile singularity \
	-resume \
	--input ${INPUT_FILE} \
	--fasta ${FASTA} \
	--fasta_index ${FASTA_INDEX} \
  --bwa_index ${BWA_INDEX} \
	--skip_fastqc \
	--complexity_filter_poly_g \
	--run_adna_trim \
	--adna_trim_path '/<PathTo>/shyrav/resources/adna/adna-trim' \
	--shard_bwa \
  --chunk_size 10000000 \
  --mapper 'bwaaln' \
  --bwaalnn 0.01 \
  --bwaalno 2 \
  --bwaalnl 1024 \
	--bam_unmapped_type 'discard' \
 	--run_bam_filtering \
	--bam_mapping_quality_threshold 20 \
  --clip_min_read_quality 20 \
	--run_genotyping \
	--genotyping_tool 'pileupcaller' \
	--genotyping_source 'raw' \
	--dedupper 'dedup' \
	--dedup_all_merged \
	--run_mtnucratio \
  --mtnucratio_header 'MT' \
	--run_nuclear_contamination \
  --pileupcaller_method 'randomHaploid' \
	--pileupcaller_bedfile '/<PathTo>/Twist_targets_march2024.pos' \
	--pileupcaller_snpfile '/<PathTo>/Twist_targets_march2024.snp' \
	--run_sexdeterrmine \
	--sexdeterrmine_bedfile '/<PathTo>/dbsnp_138_b37/biallelic_dbsnp_138.b37.pos'
