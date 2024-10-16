#!/bin/bash
#SBATCH -p ochoalab --account=ochoalab
#SBATCH --job-name=dl
#SBATCH --output=dl.out
##SBATCH --mem=64G
##SBATCH --ntasks-per-node=92
#SBATCH --mail-user=alejandro.ochoa@duke.edu
#SBATCH --mail-type=END,FAIL

#module load R/4.1.1-rhel8

~/sratoolkit.3.0.7-centos_linux64/bin/prefetch --ngc ~/prj_29151.ngc cart_hchs-sol-v2.krt --max-size u

#module unload R/4.1.1-rhel8
