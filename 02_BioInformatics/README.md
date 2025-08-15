### Pre-processing
Shotgun metagenomic libraries from sequencing run YYYY were pre-processed using the [nf-core/eager] (https://github.com/nf-core/eager) pipeline with aDNA-trim
### Initial metagenomic screening
The aDNA-trimmed libraries were parsed through [krakenUniq] (https://github.com/fbreitwieser/krakenuniq) metagenomic classifier - see script run_krakenUniq.sh 
The output matrix
### Filtered workflow targetting human DNA
