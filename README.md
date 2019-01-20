# titan
ATAC-seq analysis pipeline (in progress)

# Overview

The **titan** pipeline accepts fastq files, various QC files (reads and ATAC), called peaks, and nucleosome positioning and occupancy files.  

The pipeline is based on three existing piplines (https://github.com/harvardinformatics/ATAC-seq#peak), (https://github.com/ParkerLab/ATACseq-Snakemake), and (https://github.com/crazyhottommy/pyflow-ATACseq) taking steps or inspiration from each at various steps.

**titan** performs the following steps:

_Steps_
 - Read quality asessment (`FastQC`, `FastQScreen`)
 - Read trimming (`NGmerge`)
 - Read alignment (`BWA mem`)
 - Alignment file sorting and indexing (`samtools sort` and `index`)
 - Marking duplicate reads (`Picard MarkDuplicates`)
 - Filter reads (`samtools view`)
 - `-f 3` - keep only properly paired, properly mapped
 - `-F 4` - exclude non-mapping reads
 - `-F 8` - exclude read where mate was non-mapping
 - `-F 256` - exclude multi-mapping reads
 - `-F 1024` - exclude PCR or optical duplicates
 - `-F 2048` - exclude reads aligning to different regions
 - Convert sam (paired-end reads) to bed, calculate fragment  size (`SAMtoBED2.py`)
 - Call peaks (`MACS2`)
 - Nucleosome positioning and occupancy calling (`NucleoATAC`)
 - Peak viewing/QC (`ataqv`, `phantompeakqualtools`)

**titan** is implemented in Snakemake and makes use of several bioinformatic tools. Two main files (`titan.smk` and `config.yaml`) and a host of supporting files/directories (`rules/`, `snakemake_env.yml`) are necessary. See below.

```
git clone https://github.com/umich-brcf-bioinf-projects/titan.git
cd path/to/titan
```

After cding into `titan/`, you will see:
 - the Snakefile, `titan.smk`
 - the example configfile, `config.yaml`
 - the main snakemake environment from which to execute the pipeline, `snakemake_env`
 - the `rules/` directory, which houses the rules and accompanying environments to be created during the run, in `rules/envs/`. 
 
 The directory structure is shown below:
 ```
$ tree
.
├── README.md
├── config.yaml
├── rules
│   ├── bwa_align.smk
│   ├── bwa_index.smk
│   ├── collect_beds.smk
│   ├── envs
│   │   ├── bbmap_env.yml
│   │   ├── bwa_env.yml
│   │   ├── fastqc_env.yml
│   │   ├── fastqscreen_env.yml
│   │   ├── multiqc_env.yml
│   │   ├── ngmerge_env.yml
│   │   ├── picard_env.yml
│   │   ├── samtools_env.yml
│   │   └── star_env.yml
│   ├── fastq_screen_biotype.smk
│   ├── fastq_screen_multi.smk
│   ├── fastqc.smk
│   ├── filter_bam.smk
│   ├── get_fastq.smk
│   ├── get_refs.smk
│   ├── macs2.smk
│   ├── mark_duplicates.smk
│   ├── merge_counts.smk
│   ├── multiqc.smk
│   ├── populate_collected_beds.smk
│   ├── sam_to_bed.smk
│   ├── sort_index_bam.smk
│   └── trim.smk
├── scripts
│   ├── SAMtoBED.py
│   ├── SAMtoBED2.py
│   └── removeChrom.py
├── snakemake_env.yml
└── titan.smk

3 directories, 33 files
```

2. Create the `snakemake_env` to run **microraptor**. This will create a `conda` environment (named `snakemake_env`) that contains Snakemake, the correct version of Python, and several other dependencies necessary for running the pipeline.
```
conda env create --name snakemake_env --file snakemake_env.yml
```

Check environment installation via:
```
conda info --envs
```

You should see a `snakemake_env` in the list of `conda` environments.


# Usage

1. To run **titan**, `anaconda` or `conda` must be loaded. Check for `conda` using:   
```
conda --version
```

Conda can be loaded on Flux with:
```
module load python-anaconda3/latest-3.6
```


2. Load the correct environment, `snakemake_env` (see Installation):
```
source activate snakemake_env
```


3. Once loaded, edit the `config.yaml` file and run the pipeline via:
```
snakemake --configfile config.yaml --snakefile microraptor.smk -p --use-conda --cores 40
```

The `-p` flag is optional. The `-n` flag can be used to perform a `dry-run`, checking to see which rules should be run and how many times. The `--cores` flag can be set as you prefer. 

# Notes

At the moment, the pipeline supports  input of fastq files in the format output by the UM DNA-sequencing Core (Run_####/piname/Sample_119226/119226_TAAGGCGA-ATAGAGAG_S1_L007_R1_001.fastq.gz).  This can be changed in a later version of the pipeline.  
