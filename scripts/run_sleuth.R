suppressWarnings(library(argparse))
suppressWarnings(library(sleuth))

parser = ArgumentParser()
parser$add_argument('-i', '--input', nargs='+', required=TRUE, help='List of path to kallisto outputs')
parser$add_argument('-m', '--manifest', required=TRUE, help='Manifest file that contains sample name, condition info.')
parser$add_argument('-o', '--output', required=TRUE, help='Output DEG table.')
parser$add_argument('-t', '--threads', type='integer', default=1)
args = parser$parse_args()

options(mc.cores=args$threads)

path_list = dirname(args$input)
manifest = read.csv(args$manifest, stringsAsFactors=F)
manifest$sample = manifest$name
manifest$path = as.character(path_list)

#
# Run sleuth.
#
so = sleuth_prep(manifest, extra_bootstrap_summary=TRUE)
so = sleuth_fit(so, ~condition, 'full')
so = sleuth_fit(so, ~1, 'reduced')
so = sleuth_lrt(so, 'reduced', 'full')

# Save sleuth result to output file.
sleuth_table = sleuth_results(so, 'reduced:full', 'lrt', show_all=FALSE)
write.csv(sleuth_table, args$output, quote=FALSE, row.names=FALSE)
