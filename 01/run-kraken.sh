#!/bin/bash

# Directory containing the FASTQ files
FASTQ_DIR="/<pathTo>/CloggsEagerResults/aDNA_trim"

# Find all FASTQ files in the specified directory
FASTQ_FILES=$(find "$FASTQ_DIR" -type f -name "*.gz")

# Loop over each FASTQ file
for FASTQ in $FASTQ_FILES; do
    PREFIX=$(basename "$FASTQ" .gz) # Strip .gz extension to use as prefix

    sbatch -J krakenUniq_${PREFIX} -D /<pathTo>/krakenuni_nt/ -o /<pathTo>/krakenuni_nt/${PREFIX}_krakenUniq.out -N 1 -c 64 -p icelake \
        --mem=150GB --time=08:00:00 \
        --export DB=/hpcfs/groups/acad_users/shyrav/resources/krakenUniq/KrakenUniq_database_based_on_full_NCBI_NT_from_December_2020/,fastq=${FASTQ},prefix=${PREFIX},SIZE=100,CPU=64 \
        kraken.sh
done
