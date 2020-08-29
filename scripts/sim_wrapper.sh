#!/bin/sh

for RUN in {0001..0050}
do
  sbatch deploy_sim.sh 7 false random_$RUN
  sleep .1
  sbatch deploy_sim.sh 7 true qpControl_$RUN
  sleep .1
done

for RUN in {0051..0100}
do
  sbatch deploy_sim.sh 31 false random_$RUN
  sleep .1
  sbatch deploy_sim.sh 31 true qpControl_$RUN
  sleep .1
done
