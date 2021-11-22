#!/bin/bash
#SBATCH --job-name=ld-prune-tgp-nygc
#SBATCH --output=ld-prune-tgp-nygc.out
#SBATCH --mem=16G
#SBATCH --ntasks-per-node=4
#SBATCH --mail-user=alejandro.ochoa@duke.edu
#SBATCH --mail-type=END,FAIL

module load Plink/2.00a3LM

name=tgp-nygc-autosomes
time plink2 --bfile $name --indep-pairwise 1000kb 0.3 --out $name --threads 4 --memory 16000

module unload Plink/2.00a3LM
