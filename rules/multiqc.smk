ALL.extend([QC_DIR + 'multiqc_report.html',])

rule multiqc:
    input:
        expand('{directory}{sample}{extension}', #log
              directory = ALN_DIR,
              sample = SAMPLE_NAMES,
              extension = '_starLog.final.out'), 
        expand('{directory}{sample}{extension}', #counts
              directory = COUNTS_DIR,
              sample = SAMPLE_NAMES,
              extension = '_starReadsPerGene.out.tab'), 
        expand('{directory}{sample}_{read}{extension}', #fastqc raw
              directory = QC_DIR,
              sample = SAMPLE_NAMES,
              read = READS,
              extension = '_fastqc.zip'),

    output:
        QC_DIR + 'multiqc_report.html',
    params:
        QC_DIR,
        ALN_DIR,
        COUNTS_DIR
    conda:
        'envs/multiqc_env.yml'
    shell:
        """
        multiqc \
        --force \
        -s \
        --interactive \
        -n {output} \
        {params}
        """
