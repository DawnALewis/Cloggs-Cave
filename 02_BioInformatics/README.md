### Sequencing runs overview

### Pre-processing
Shotgun metagenomic libraries  were pre-processed using the [nf-core/eager](https://github.com/nf-core/eager) pipeline with aDNA-trim and sharding integration per [shyama-mama](https://github.com/shyama-mama/eager/tree/v2.4.5-sharding) 
### Initial metagenomic screening
The aDNA-trimmed libraries were parsed through [krakenUniq](https://github.com/fbreitwieser/krakenuniq) metagenomic classifier - see script [run_krakenUniq.sh](https://github.com/DawnALewis/Cloggs-Cave/02_BioInformatics/run-kraken.sh)
The output matrix

### Eager Pipeline to filter libraries for target reads


### Filtered workflow targetting human DNA using the metascreen pipeline
This nextflow pipeline was developed by [Shyamsundar Ravishankar](https://github.com/shyama-mama/) 

BWA output (.BAM files) are split by reference species into four .BAMs due to size. To do this, make a list of contigs for each reference species. This is has the potential to lose reads which have mapped to multiple species. Small libraries may be able to avoid this splitting. 
The split .BAMs then undergo Basic Local Alignment Search Tool (BLAST) and Lowest Common Ancestor (LCA) assignment using conservative parameters (see Supplementary Information for LCA parameter testing). 
DNA damage is then assessed by MapDamage against the original species reference. 

### Workflow for human capture Data
