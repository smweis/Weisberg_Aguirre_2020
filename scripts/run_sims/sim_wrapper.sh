#!/bin/sh

for RUN in {0001..0050}
do
  for nOutcomes in 7 15
  do
    for noise in .05 .15 .25
    do
      sbatch deploy_sim.sh $nOutcomes $noise false random_${nOutcomes}_${noise}_${RUN}
      sleep .1
      sbatch deploy_sim.sh $nOutcomes $noise true qpControl_${nOutcomes}_${noise}_${RUN}
      sleep .1
    done
  done
done
