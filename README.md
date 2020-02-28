# snakemake-kallisto-sleuth

Kallisto-Sleuth pipeline in snakemake.

## Quickstart

1. Clone the repo.

```
$ git clone https://github.com/dohlee/snakemake-kallisto-sleuth.git
$ cd snakemake-kallisto-sleuth
```

2. Modify the configurations manifest file as you want.

3. Run the pipeline.

If you already have snakemake installed, it might be useful to just use `--use-conda` option. Tweak `-j` parameter according to the number of available cores on your system.

```
$ snakemake --use-conda -p -j 32
```

Or you can create separate environment for this pipeline and run it.

```
$ conda env create -f environment.yaml
$ snakemake -p -j 32
```
