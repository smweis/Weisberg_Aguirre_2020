#!/bin/sh
# A wrapper for deploy_sim.sh to run that script in a loop for parameters you want to vary.
for RUN in {0001..0050}
do
  for nOutcomes in 7 15
  do
    for noise in .05 .10 .15
    do
      for trialLength in 8 12
      do
        for TR in 800 1600
        do
          sbatch deploy_sim.sh $nOutcomes $noise $trialLength $TR false random_${nOutcomes}_nOutcomes_${noise}_noise_${TR}_TR_${trialLength}_trialLength_${RUN}
          sleep .05
          sbatch deploy_sim.sh $nOutcomes $noise $trialLength $TR true qpControl_${nOutcomes}_nOutcomes_${noise}_noise_${TR}_TR_${trialLength}_trialLength_${RUN}
          sleep .05
        done
      done
    done
  done
done
