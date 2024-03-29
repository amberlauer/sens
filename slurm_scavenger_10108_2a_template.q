#!/bin/bash
#SBATCH --partition scavenger
#SBATCH --job-name=sensitivity_10108_number
#SBATCH --output=errors/slurm._%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3072
#SBATCH --array=numero00-number00
#SBATCH --mail-type=END
#SBATCH --mail-user=amberlauer@gmail.com
#SBATCH -e errors/slurm._%A_%a.err


export MESA_DIR=/hpc/group/physics/al363/mesa10108
export MESASDK_ROOT=/hpc/group/physics/al363/mesasdk_11_2017
#export MESASDK_ROOT=~/mesasdk_8_18
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh
export MESA_BASE=/work/al363/new_sens/base
export MESA_INLIST=$MESA_BASE/inlist
export MESA_RUN=$MESA_BASE/runs_xfactor_number

#mkdir $MESA_BASE/runs_x100_number
cd $MESA_RUN

shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line
let "index1=${SLURM_ARRAY_TASK_ID}*2"
let "index2=${index1}-1"

# Check for empty files using arrays
empty=false
test "$(ls -A ./${index2}/photos)"&& empty=false || empty=true


if $empty; then
    echo "starting from scratch "
    mkdir $MESA_RUN/${index2}
    cd $MESA_RUN/${index2}
    cat $MESA_BASE/inlist_cluster_templatefactor_1b > ./inlist_cluster
    rxn1=$(sed -n ''${index2}'p' $MESA_BASE/reaction_list_305_10108.txt)
    sed -i 's|reaction_name1|'$rxn1'|g'  inlist_cluster
    rxn2=$(sed -n ''${index1}'p' $MESA_BASE/reaction_list_305_10108.txt)
    sed -i 's|reaction_name2|'$rxn2'|g'  inlist_cluster
    $MESA_BASE/star >> /work/al363/new_sens/errors/slurm._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err

else
    cd $MESA_RUN/${index2}
    if ls ./final_profile* 1> /dev/null 2>&1; then
    	echo "this_model_is_finished"  >> /work/al363/new_sens/errors/slurm._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 
    else	
    	echo "starting from photo" >> /work/al363/new_sens/errors/slurm._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 

    	cd ./photos
    	cp $(ls -t  | head -1) restart_photo
    	cd ../   date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
    	if [[ -e star.exe ]];then
        $MESA_BASE/star.exe
    	else
        $MESA_BASE/star >> /work/al363/new_sens/errors/slurm._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 
    	fi
    	date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
     fi		
fi


#Run Mesa
#$MESA_BASE/star

#srun hostname
#srun sleep 60

shopt -u nullglob
shopt -u dotglob


