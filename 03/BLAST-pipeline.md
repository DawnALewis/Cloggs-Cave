The libraries filtered with the concatenated reference aligned with BWA, will have a large amount of erroneous reads that will overwhelmed trace species (e.g. human). In order to clean these filtered libraries, we split each library bam by species and then BLAST each split library. We then run mapDamage on the BLAST-asigned species reads against their original reference genome to ascertain damage profiles. 

```
#!/bin/bash

module load Nextflow/21.03.0

FASTA=/hpcfs/groups/acad_users/dawn/validation/references/Cloggs_reference_May2025/four_species.fna
HUMAN_CONTIGS=/hpcfs/groups/acad_users/dawn/validation/references/Cloggs_reference_May2025/Human.contigs
RABBIT_CONTIGS=/hpcfs/groups/acad_users/dawn/validation/references/Cloggs_reference_May2025/Rabbit.contigs
WALLABY_CONTIGS=/hpcfs/groups/acad_users/dawn/validation/references/Cloggs_reference_May2025/Wallaby.contigs
DOG_CONTIGS=/hpcfs/groups/acad_users/dawn/validation/references/Cloggs_reference_May2025/Dog.contigs


nextflow run metagenomic_screening.nf -c metagenomic_screening.config \
    --inputFile inputFile.tsv --human_contig ${HUMAN_CONTIGS} --wallaby_contig ${WALLABY_CONTIGS} \
    --rabbit_contig ${WALLABY_CONTIGS} --Dog_contig ${DOG_CONTIGS} --fasta ${FASTA} \
    --minPercentIdentity 95 --minSupportPercent 0.001 --lcaCoveragePercent 80 -resume
```

The input file is a tsv with Library, BAM location, BAM index location

