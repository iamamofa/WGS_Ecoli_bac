#!/bin/bash
#SBATCH --job-name=wgs_postproc
#SBATCH --output=logs/wgs_postproc.out
#SBATCH --error=logs/wgs_postproc.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=6:00:00

module load roary mafft iqtree R

roary -p 16 -e -n -v results/prokka/*.gff
mafft --auto results/pangenome/core_gene_alignment.aln > results/pangenome/core_alignment.aln
iqtree -s results/pangenome/core_alignment.aln -T 16
Rscript scripts/visualize.R results/phylogeny/core
