#ATAC-seq
#Christopher Sifuentes cjsifuen@umich.edu

from __future__ import print_function, absolute_import, division
from argparse import Namespace
import collections
from collections import defaultdict
import csv
from functools import partial
from functools import reduce
import glob
import hashlib
import os
from os.path import basename
from os.path import isfile
from os.path import join
from os.path import splitext
import shutil
import sys
import subprocess
import yaml
import datetime
import time
import snakemake
import pandas as pd
#from persistentlist import PersistentList


#email
EMAIL = config.get('email_address')

#get parameters from config file
TODAY = datetime.date.today()
DEFAULT_JOB_SUFFIX = 'analysis_{:02d}_{:02d}/'.format(TODAY.month, TODAY.day)
SUFFIX = config['analysis_dir_suffix']

#pjdir
if not SUFFIX:
    PJ_SUFFIX = DEFAULT_JOB_SUFFIX
else:
    PJ_SUFFIX = SUFFIX

PJ_DIR = config.get('project_dir')

#make other dir names
ANALYSIS_DIR = PJ_DIR + PJ_SUFFIX
REF_DIR = ANALYSIS_DIR + 'references/'
FASTQ_DIR = ANALYSIS_DIR + 'fastq/'
QC_DIR = ANALYSIS_DIR + 'fastq_qc/'
MULTI_DIR = QC_DIR + 'multi_species/'
BIOTYPE_DIR = QC_DIR + 'biotype/'
TRIM_DIR = ANALYSIS_DIR + 'fastq_trimmed/'
ALN_DIR = ANALYSIS_DIR + 'aligned/'
MD_DIR = ANALYSIS_DIR + 'mark_duplicates/'
PEAKS_DIR = ANALYSIS_DIR + 'peaks/'
LOG_DIR = ANALYSIS_DIR + 'logs/'
BENCH_DIR = ANALYSIS_DIR + 'benchmark/'


#make pjdir
if not os.path.exists(ANALYSIS_DIR):
    os.makedirs(ANALYSIS_DIR)

#organism base names
ORG = config['genome']

#get sample base names
SAMPLE_NAMES = os.listdir(config['input_dir']['fastq'])
SAMPLE_ID = [(x).split('_')[1] for x in SAMPLE_NAMES]

#read extensions (paired)
READS = config['read_info']['paired_ext']

#set empty all list
ALL = []
COLLECTED_BEDS = []

if os.path.exists(MD_DIR + 'Collect_beds.done'):
    bed_list=pd.read_csv(MD_DIR + 'Collect_beds.done', delimiter=',')
    COLLECTED_BEDS.extend(bed_list)


#load rules
include: 'rules/get_fastq.smk'
include: 'rules/fastqc.smk'
include: 'rules/fastq_screen_multi.smk'
include: 'rules/fastq_screen_biotype.smk'
include: 'rules/trim.smk'
include: 'rules/get_refs.smk'
include: 'rules/bwa_index.smk'
include: 'rules/bwa_align.smk'
include: 'rules/sort_index_bam.smk'
include: 'rules/mark_duplicates.smk'
include: 'rules/filter_bam.smk'
include: 'rules/sam_to_bed.smk'
include: 'rules/collect_beds.smk'
# include: 'rules/macs2.smk'
# include: 'rules/multiqc.smk'

print(COLLECTED_BEDS)
#rule all
rule all:
    input:
        ALL,

#email success
onsuccess:
    syscmd2 = "echo -e 'Denver ATAC: workflow complete.' | mutt -s 'Workflow finished, no error' " + EMAIL
    os.system(syscmd2)

onerror:
    syscmd2 = "echo -e 'Denver ATAC: workflow error.' | mutt -s 'Workflow failed with error' " + EMAIL
    os.system(syscmd2)
