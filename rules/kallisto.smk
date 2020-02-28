c = config['kallisto_index']
rule kallisto_index:
    input:
        # Required input.
        config['reference']['fasta']
    output:
        # Required output.
        config['index']['kallisto']
    params:
        # Optional parameters. It omitted, default value will be used.
        extra = '',
    threads: 1  # Multithreading not supported.
    log: 'logs/kallisto_index.log'
    wrapper:
        'http://dohlee-bio.info:9193/kallisto/index'

c = config['kallisto_quant']
def kallisto_input(wildcards):
    lib = SAMPLE2LIB[wildcards.sample]
    ret = {'index': config['index']['kallisto']}

    if lib.upper().startswith('SINGLE'):
        ret['fastq'] = [
            str(DATA_DIR / '{sample}.fastq.gz')
        ]
    else:
        ret['fastq'] = [
            str(DATA_DIR / '{sample}.read1.fastq.gz'),
            str(DATA_DIR / '{sample}.read2.fastq.gz'),
        ]

    return ret

def fragment_length_param(wildcards, input):
    if len(input.fastq) == 2:
        return ''
    else:
        return c['fragment_length']

def standard_deviation_param(wildcards, input):
    if len(input.fastq) == 2:
        return ''
    else:
        return c['standard_deviation']

rule kallisto_quant:
    input: unpack(kallisto_input)
    output:
        # Required output.
        RESULT_DIR / '02_kallisto' / '{sample}' / 'abundance.tsv',
        RESULT_DIR / '02_kallisto' / '{sample}' / 'abundance.h5',
        RESULT_DIR / '02_kallisto' / '{sample}' / 'run_info.json',
    params:
        # Optional parameters. It omitted, default value will be used.
        extra = c['extra'],
        # Required parameters for single-end reads.
        fragment_length = fragment_length_param,
        standard_deviation = standard_deviation_param,
    threads: config['threads']['kallisto_quant']
    log: 'logs/kallisto_quant/{sample}.log'
    wrapper:
        'http://dohlee-bio.info:9193/kallisto/quant'

