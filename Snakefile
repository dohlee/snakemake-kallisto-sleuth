import pandas as pd
from pathlib import Path

configfile: 'config.yaml'

manifest = pd.read_csv(config['manifest'])
DATA_DIR = Path(config['data_dir'])
RESULT_DIR = Path(config['result_dir'])

include: 'rules/kallisto.smk'
include: 'rules/fastqc.smk'

SAMPLES = manifest.name.values
SAMPLE2LIB = {r.name:r.library_layout for r in manifest.to_records()}
SE_SAMPLES = manifest[manifest.library_layout == 'single'].name.values
PE_SAMPLES = manifest[manifest.library_layout == 'paired'].name.values

RAW_QC_SE = expand(str(DATA_DIR / '{sample}_fastqc.zip'), sample=SE_SAMPLES)
RAW_QC_PE = expand(str(DATA_DIR / '{sample}.read1_fastqc.zip'), sample=PE_SAMPLES)
ABUNDANCE = expand(str(RESULT_DIR / '02_kallisto' / '{sample}' / 'abundance.tsv'), sample=SAMPLES)
DEG = RESULT_DIR / '03_sleuth' / 'sleuth_result.csv'

ALL = []
ALL.append(RAW_QC_SE)
ALL.append(RAW_QC_PE)
ALL.append(ABUNDANCE)
ALL.append(DEG)

rule all:
    input: ALL

rule clean:
    shell:
        "if [ -d {RESULT_DIR} ]; then rm -r {RESULT_DIR}; fi; "
        "if [ -d {DATA_DIR} ]; then rm -r {DATA_DIR}; fi; "
        "if [ -d logs ]; then rm -r logs; fi; "
        "if [ -d benchmarks ]; then rm -r benchmarks; fi; "

rule sleuth:
    input:
        ABUNDANCE
    output:
        RESULT_DIR / '03_sleuth' / 'sleuth_result.csv'
    params:
        manifest = config['manifest']
    threads: config['threads']['sleuth']
    shell:
        'Rscript scripts/run_sleuth.R '
        '-i {input} '
        '-o {output} '
        '-m {params.manifest} '
        '-t {threads} '
