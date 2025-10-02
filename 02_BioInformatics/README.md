### Sequencing runs overview

### Pre-processing
Shotgun metagenomic libraries  were pre-processed using the [nf-core/eager](https://github.com/nf-core/eager) pipeline with aDNA-trim and sharding integration per [shyama-mama](https://github.com/shyama-mama/eager/tree/v2.4.5-sharding). Trimmed files were mapped to with BWA to the concatenated reference file without quality thresholds to account for multi-species read mapping. See shotgun_run_eager.sh 

### Initial metagenomic screening
The aDNA-trimmed libraries classified using the k-mer based [krakenUniq](https://github.com/fbreitwieser/krakenuniq) metagenomic classifier - see script [run_krakenUniq.sh](https://github.com/DawnALewis/Cloggs-Cave/blob/main/02_BioInformatics/run-kraken.sh)
The output matrix identified 

### Filtered workflow targetting human DNA from shotgun data using the metascreen pipeline
This nextflow pipeline was developed by [Shyamsundar Ravishankar](https://github.com/shyama-mama/) 

BWA output (.BAM files) from Eager are split by reference species into four .BAMs due to size. To do this, make a list of contigs for each reference species. This is has the potential to lose reads which could map to multiple species and are therefore randomly assigned in BWA. Small libraries may be able to avoid this splitting. 
The split .BAMs then undergo Basic Local Alignment Search Tool (BLAST) and Lowest Common Ancestor (LCA) assignment using conservative parameters (see Supplementary Information for LCA parameter testing). 
DNA damage is then assessed by MapDamage against the original species reference. 

### Workflow for human capture Data

Human capture data were pre-processed using the [nf-core/eager](https://github.com/nf-core/eager) pipeline with aDNA-trim and sharding integration per [shyama-mama](https://github.com/shyama-mama/eager/tree/v2.4.5-sharding). Libraries were mapped against the human reference genome GRCh37d5. See [capture_run_eager.sh](https://github.com/DawnALewis/Cloggs-Cave/blob/main/02_BioInformatics/capture_run_eager.sh) for full parameters. Damage Profiler is the only damage profiler availabel in the bespoke pipeline and so output was re-assessed with MapDamage for consistency.
