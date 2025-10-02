#!/usr/bin/env nextflow

// Default params
params.minPercentIdentity = 95
params.minSupportPercent = 0.01
params.lcaCoveragePercent = 80


Channel.fromPath(params.inputFile)
    .splitCsv(header: false, sep: '\t')
    .map{
        it -> 
        def prefix = it[0]
        def bam = file(it[1])
        def bai  = file(it[2])
        [ prefix, bam, bai ]
    }
    .set { ch_input }


// Required Args
human_contig = params.human_contig
wallaby_contig = params.wallaby_contig
rabbit_contig = params.rabbit_contig
dog_contig = params.dog_contig
fasta = params.fasta

// Optional Args
minPercentIdentity = params.minPercentIdentity
minSupportPercent = params.minSupportPercent
lcaCoveragePercent = params.lcaCoveragePercent

process splitbambyspecies {
    tag "${prefix}"
    publishDir("results/${prefix}/", mode: "copy")

    input:
    tuple prefix, file(bam), file(bai) from ch_input

    output:
    tuple prefix, wallaby, file("${prefix}_${wallaby}.bam") into ch_wallaby_bams
    tuple prefix, wallaby, file("${prefix}_${wallaby}.fasta") into ch_wallaby_fasta
    tuple prefix, rabbit, file("${prefix}_${rabbit}.bam") into ch_rabbit_bams
    tuple prefix, rabbit, file("${prefix}_${rabbit}.fasta") into ch_rabbit_fasta
    tuple prefix, human, file("${prefix}_${human}.bam") into ch_human_bams
    tuple prefix, human, file("${prefix}_${human}.fasta") into ch_human_fasta
    tuple prefix, dog, file("${prefix}_${dog}.bam") into ch_dog_bams
    tuple prefix, dog, file("${prefix}_${dog}.fasta") into ch_dog_fasta

    script:
    human = "human"
    wallaby = "wallaby"
    rabbit = "rabbit"
    dog = "dog"
    """
    # Extract reads per species
    samtools view -bh ${bam} \$(cat ${human_contig} | tr "\\n" " ") -o ${prefix}_${human}.bam
    samtools view -bh ${bam} \$(cat ${wallaby_contig} | tr "\\n" " ") -o ${prefix}_${wallaby}.bam
    samtools view -bh ${bam} \$(cat ${rabbit_contig} | tr "\\n" " ") -o ${prefix}_${rabbit}.bam
    samtools view -bh ${bam} \$(cat ${dog_contig} | tr "\\n" " ") -o ${prefix}_${dog}.bam

    # Make fasta from the bams
    samtools fasta ${prefix}_${human}.bam > ${prefix}_${human}.fasta
    samtools fasta ${prefix}_${wallaby}.bam > ${prefix}_${wallaby}.fasta
    samtools fasta ${prefix}_${rabbit}.bam > ${prefix}_${rabbit}.fasta
    samtools fasta ${prefix}_${dog}.bam > ${prefix}_${dog}.fasta
    """
}

ch_wallaby_bams.mix(ch_rabbit_bams, ch_human_bams, ch_dog_bams).into {  ch_species_bams_view ; ch_species_bam_for_extract_reads }

ch_wallaby_fasta.mix(ch_rabbit_fasta, ch_human_fasta, ch_dog_fasta).into { ch_species_fasta_for_megan ; ch_blast_input  ; ch_species_fasta_view }

process blast {
    tag "${prefix}_${species}"
    publishDir("results/${prefix}/${species}/", mode: "copy")

    input:
    tuple prefix, species, file(species_fasta) from ch_blast_input

    output:
    tuple prefix, species, file("${prefix}_${species}_blast.out") into ch_blast_output

    script:
    """
    blastn -db /gpfs/users/a1880987/projects/clay/blast/nt/nt \
        -query ${species_fasta} -out ${prefix}_${species}_blast.out -num_threads ${task.cpus}
    """
}

ch_species_fasta_for_megan.join(ch_blast_output, remainder: true, by:[0,1]).into {ch_megan_input ; ch_megan_input_view}

process megan {
    tag "${prefix}_${species}"
    publishDir("results/${prefix}/${species}/", mode: "copy")

    input:
    tuple prefix, species, file(species_fasta), file(blast_results) from ch_megan_input

    output:
    tuple prefix, species, file("*rma6") into ch_megan_output

    script:
    """
    blast2rma -i ${blast_results} -f BlastText -bm BlastN \
        -r ${species_fasta} --out ./ \
        --useCompression --minSupportPercent ${minSupportPercent} \
        --minPercentIdentity ${minPercentIdentity} --lcaAlgorithm weighted --lcaCoveragePercent ${lcaCoveragePercent} -t ${task.cpus}
    """
}


ch_megan_output.into { ch_get_read_ids_input ; ch_get_read_ids_input_view }

process get_read_ids {
    tag "${prefix}_${species}"
    publishDir("results/${prefix}/${species}/", mode: "copy")

    input:
    tuple prefix, species, file(rma6) from ch_get_read_ids_input

    output:
    tuple prefix, species, order, file("${prefix}_${species}_${order}_read_ids.list") into ch_get_read_ids_output
    file("${prefix}_${species}_r2c.txt")

    script:
    if(species == "human") {
        order = "Primates"
    } else if (species == "wallaby") {
        order = "Diprotodontia"
    } else if (species == "rabbit") {
        order = "Lagomorpha"
    } else if (species == "dog") {
        order = "Carnivora"
    }
    """
    rma2info -i ${rma6} -r2c Taxonomy --paths -mro -r -l -o ${prefix}_${species}_r2c.txt
    grep "\\[O\\] ${order};" ${prefix}_${species}_r2c.txt | awk '{print \$1;}' > ${prefix}_${species}_${order}_read_ids.list
    """
}

ch_species_bam_for_extract_reads.join(ch_get_read_ids_output, remainder: true, by: [0,1]).into {ch_extract_reads_input ; ch_extract_reads_input_view}

process extract_reads {
    tag "${prefix}_${species}"
    publishDir("results/${prefix}/${species}/", mode: "copy")

    input:
    tuple prefix, species, file(species_bam), order, file(read_ids) from ch_extract_reads_input

    output:
    tuple prefix, species, file("${prefix}_blast_filter_by_${order}.sam") into ch_extracted_reads

    script:
    """
    samtools view -H ${species_bam} > ${prefix}_headerbam.txt 
    samtools view ${species_bam} | grep -f ${read_ids} > ${prefix}_blast_${order}.reads 
    cat ${prefix}_headerbam.txt ${prefix}_blast_${order}.reads > ${prefix}_blast_filter_by_${order}.sam 
    """
}

process mapDamage {
    tag "${prefix}_${species}"
    publishDir("results/${prefix}/${species}/", mode: "copy")

    input:
    tuple prefix, species, file(sam) from ch_extracted_reads

    output:
    tuple prefix, species, file("results_*")

    script:
    """
    mapDamage -i ${sam} -r ${fasta} --no-stats
    """
}
