ALL.extend([expand('{directory}{sample}{extension}',
                  directory = PEAKS_DIR,
                  sample = COLLECTED_BEDS,
                  extension = '_peaks.broadPeak'),])
                    
rule macs2:
    input:
        list = MD_DIR + 'Collect_beds.done',
        beds = MD_DIR + '{sample}.filtered.bed',
    output:
        bam = PEAKS_DIR + '{sample}_peaks.broadPeak',
    params:
        format = config['macs2']['format'],
        genome_size = config['macs2']['genome_size'],
        sample = '{sample}',
        shape = config['macs2']['shape']
    log:
        
    conda:
        'envs/macs2_env.yml'
    threads: config['thread_info']['index']

    shell:
        """
        macs2 \
        callpeak \
        -t {input.beds} \
        --outdir {output} \
        -n {params.sample} \
        -g {params.genome_size} \
        --{params.shape} \
        {input.bed} \
        > {output.bam}
        rm -rf {params.tmp}
        samtools index -@ {threads} -b {output.bam}
        """
