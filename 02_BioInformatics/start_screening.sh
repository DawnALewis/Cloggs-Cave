```
#!/bin/bash

module load Nextflow/21.03.0

FASTA=/<PathTo>/references/Cloggs_reference_May2025/four_species.fna
HUMAN_CONTIGS=/<PathTo>/references/Cloggs_reference_May2025/Human.contigs
RABBIT_CONTIGS=/<PathTo>/references/Cloggs_reference_May2025/Rabbit.contigs
WALLABY_CONTIGS=/<PathTo>/references/Cloggs_reference_May2025/Wallaby.contigs
DOG_CONTIGS=/<PathTo>/references/Cloggs_reference_May2025/Dog.contigs


nextflow run metagenomic_screening.nf -c metagenomic_screening.config \
    --inputFile inputFile.tsv --human_contig ${HUMAN_CONTIGS} --wallaby_contig ${WALLABY_CONTIGS} \
    --rabbit_contig ${WALLABY_CONTIGS} --Dog_contig ${DOG_CONTIGS} --fasta ${FASTA} \
    --minPercentIdentity 95 --minSupportPercent 0.001 --lcaCoveragePercent 80 -resume
    ```
