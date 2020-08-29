#!/bin/bash
#SBATCH --job-name=sim_test    # Job name
#SBATCH --qos=stevenweisberg-b
#SBATCH --mail-type=NONE          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=stevenweisberg@ufl.edu     # Where to send mail
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=8gb                     # Job memory request
#SBATCH --time=04:00:00               # Time limit hrs:min:sec
#SBATCH --output=sim_test_%A.log   # Standard output and error log


# See details of /qpfMRI/main/compiledSimulate.m for how to call this.

sleep 1

pwd; hostname; date

ml matlab

export MCR_CACHE_ROOT=$SCRATCH

d='8.29.2020'

cd /blue/stevenweisberg/stevenweisberg/qpfMRIResults/compiled$d

./run_compiledSimulate.sh /apps/matlab/mcr/2020a/v98 \
logistic \
param1Lower '-1.2' \
param1nDivisions 10 \
param1Upper '-.2' \
param2Lower .01 \
param2nDivisions 10 \
param2Upper 1.0 \
param3Lower .75 \
param3nDivisions 11 \
param3Upper 1.25 \
param4Lower .5 \
param4nDivisions 8 \
param4Upper 4 \
param1Spacing log \
param2Spacing lin \
param3Spacing zeno \
param4Spacing lin \
param1Simulated .41 \
param2Simulated .57 \
param3Simulated 1 \
param4Simulated .15 \
stimDomainLower .01 \
stimDomainUpper 1.0 \
stimDomainnDivisions 25 \
nOutcomes $1 \
qpPres $2 \
outNum $3
