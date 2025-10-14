#!/bin/bash


ml BLAST+/2.13.0

outFile=$(basename $1 "_rmdup.bam.fna")
blastn -db /gpfs/users/a1880987/projects/clay/blast/nt/nt -query ${1} -out /gpfs/users/a1867445/Cloggs_capture/BLAST/blast_out/${outFile}_blast.out
