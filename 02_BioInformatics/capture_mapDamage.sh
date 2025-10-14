#!/bin/bash
ml Singularity
outFile=$(basename $1 "_blast.rma6")
singularity exec -B /gpfs/ /hpcfs/groups/acad_users/containers/mapdamage2_2.2.2--pyr43hdfd78af_0.sif mapDamage -i ${1} -r /hpcfs/groups/acad_users/Refs/Homo_sapiens/GATK/GRCh37/Sequence/WholeGenomeFasta/human_g1k_v37_decoy.fasta --no-stats
