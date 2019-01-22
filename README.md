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

Additionally, `ataqv` must be installed. In this pipline, it has been installed in a conda env called `ataqv_env`, though it is not available via conda. Perhaps a step will be included later on to allow one to `source activate env`, where the `env` variable is the name of a particular environment, but for the moment, it is hard-coded as `ataqv_env`. Thus, an env must be created with that name, containing `ataqv`.

1. Create `ataqv_env` and activate it.
```
conda create -n ataqv_env -y
conda activate ataqv_env
```

2. Download `ataqv`, untar and copy the `bin/` and `share/` sub-directories into the `ataqv_env` `bin/` and `share/` subdirectories. _Note: The bin and share directories should not yet be present if this is a fresh ataqv_env._

A simple example:
```
wget https://github.com/ParkerLab/ataqv/releases/download/1.0.0/ataqv-1.0.0.x86_64.Linux.tar.gz
tar xzf ataqv-1.0.0.x86_64.Linux.tar.gz
cd ataqv-1.0.0/
cp -r bin/ /home/cjsifuen/miniconda3/envs/ataqv_env/
cp -r share/ /home/cjsifuen/miniconda3/envs/ataqv_env/
```

3. Exit the `ataqv_env` and proceed with installing the pipeline.
```
conda deactivate
```

4. Clone the repo.

```
git clone https://github.com/umich-brcf-bioinf-projects/titan.git
cd path/to/titan
```

After cding into `titan/`, you will see:
 - the Snakefile, `titan.smk`
 - the example configfile, `config.yaml`
 - the main snakemake environment from which to execute the pipeline, `snakemake_env`
 - the `rules/` directory, which houses the rules and accompanying environments to be created during the run, in `rules/envs/`. 
 
5. Create the `snakemake_env` to run **titan**. This will create a `conda` environment (named `snakemake_env`) that contains Snakemake, the correct version of Python, and several other dependencies necessary for running the pipeline.
```
conda create -n snakemake_env --file snakemake_env.yml
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
snakemake --configfile config.yaml --snakefile titan.smk -p --use-conda --cores 40
```

The `-p` flag is optional. The `-n` flag can be used to perform a `dry-run`, checking to see which rules should be run and how many times. The `--cores` flag can be set as you prefer. 

# Notes

At the moment, the pipeline supports  input of fastq files in the format output by the UM DNA-sequencing Core (Run_####/piname/Sample_119226/119226_TAAGGCGA-ATAGAGAG_S1_L007_R1_001.fastq.gz).  This can be changed in a later version of the pipeline.  
