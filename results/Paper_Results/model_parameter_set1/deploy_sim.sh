#!/bin/bash
#SBATCH --job-name=model_parameter_set1    # Job name
#SBATCH --qos=stevenweisberg-b
#SBATCH --mail-type=NONE          # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=stevenweisberg@ufl.edu     # Where to send mail
#SBATCH --ntasks=1                    # Run on a single CPU
#SBATCH --mem=8gb                     # Job memory request
#SBATCH --time=04:00:00               # Time limit hrs:min:sec
#SBATCH --output=model_parameter_set1_%A.log   # Standard output and error log


sleep 1

pwd; hostname; date

# Hipergator specific commands
ml matlab
export MCR_CACHE_ROOT=$SCRATCH

# Names of the compiled folder and the output folder
d='09.20.2020'
outFolder='model_parameter_set1'
# Where is your compiled Matlab script?
cd /blue/stevenweisberg/stevenweisberg/qpfMRIResults/compiled.$d
# Make copies of the deploy_sim and sim_wrapper scripts for reproducibility
# Save them with the results
mkdir /blue/stevenweisberg/stevenweisberg/qpfMRIResults/$outFolder/
cp /blue/stevenweisberg/stevenweisberg/qpfMRIResults/deploy_sim.sh /blue/stevenweisberg/stevenweisberg/qpfMRIResults/$outFolder/
cp /blue/stevenweisberg/stevenweisberg/qpfMRIResults/sim_wrapper.sh /blue/stevenweisberg/stevenweisberg/qpfMRIResults/$outFolder/

# Make sure this is the most recent version of the compiler
# Below this are all of the parameters to pass to compiledSimulate.m
# See compiledSimulate.m for details
./run_compiledSimulate.sh /apps/matlab/mcr/2020b/v99 \
logistic \
nParams 4 \
param1Name slope \
param2Name semiSat \
param3Name beta \
param4Name sigma \
param1Lower "-2" \
param1nDivisions 20 \
param1Upper 0 \
param2Lower .01 \
param2nDivisions 10 \
param2Upper 1.0 \
param3Lower .5 \
param3nDivisions 11 \
param3Upper 1.5 \
param4Lower .01 \
param4nDivisions 20 \
param4Upper 1.0 \
param1Spacing log \
param2Spacing lin \
param3Spacing zeno \
param4Spacing lin \
stimDomainLower .01 \
stimDomainUpper 1.0 \
stimDomainnDivisions 30 \
stimDomainSpacing lin \
nTrials 30 \
trialLength $3 \
TR $4 \
param1Simulated .41 \
param2Simulated .57 \
param3Simulated 1.0 \
param4Simulated $2 \
outFolder $outFolder \
nOutcomes $1 \
noiseSD $2 \
qpPres $5 \
outNum $6
