#!/bin/bash
#SBATCH --partition scavenger
#SBATCH --job-name=sensitivity_10108_3
#SBATCH --output=errors/slurm._%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3072
#SBATCH --array=-100--105
#SBATCH --mail-type=END
#SBATCH --mail-user=amberlauer@gmail.com
#SBATCH -e errors/slurm._%A_%a.err


export MESA_DIR=/hpc/group/physics/al363/mesa10108
export MESASDK_ROOT=/hpc/group/physics/al363/mesasdk_11_2017
#export MESASDK_ROOT=~/mesasdk_8_18
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh
export MESA_BASE=/hpc/group/physics/al363/sens/base
export MESA_INLIST=$MESA_BASE/inlist
export MESA_RUN=/work/al363/runs/runs_x.01_3

#mkdir $MESA_BASE/runs_x100_3
cd $MESA_RUN

shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line
let "index=${SLURM_ARRAY_TASK_ID}"
let "index1=${SLURM_ARRAY_TASK_ID}*2"
let "index2=${index1}-1"

# Check for empty files using arrays
#empty=false
#test "$(ls -A ./${index2}/photos)"&& empty=false || empty=true

cd $MESA_RUN/${index2}
cat $MESA_BASE/inlist_cluster_abund_template.01 > ./inlist_cluster
rxn1=$(sed -n ''${index2}'p' $MESA_BASE/reaction_list_305_10108.txt)
sed -i 's|reaction_name1|'$rxn1'|g'  inlist_cluster
rxn2=$(sed -n ''${index1}'p' $MESA_BASE/reaction_list_305_10108.txt)
sed -i 's|reaction_name2|'$rxn2'|g'  inlist_cluster
max_model=$(sed -n ''${index})'p' $MESA_BASE/max_model.txt
sed -i 's|max_3|'$max_model'|g'  inlist_cluster
model=$(sed -n ""${index})'p' $MESA_BASE/restart_model.txt
cd ./photos
./re ${model} >> /work/al363/new_sens/errors/slurm._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 
date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"



#Run Mesa
#$MESA_BASE/star

#srun hostname
#srun sleep 60

shopt -u nullglob
shopt -u dotglob


