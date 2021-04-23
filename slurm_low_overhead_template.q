#!/bin/bash
#SBATCH --partition common,scavenger
#SBATCH --job-name=sens_xfactor_number_low_O
#SBATCH --output=errors/xfactor_number._%A_%a.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3072
#SBATCH --array=numero01-numero5
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=amberlauer@gmail.com
#SBATCH -e errors/xfactor_number._%A_%a.err



export MESA_DIR=/hpc/group/physics/al363/mesa10108
export MESASDK_ROOT=/hpc/group/physics/al363/mesasdk_11_2017
#export MESASDK_ROOT=~/mesasdk_8_1 8
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh
export MESA_BASE=/hpc/group/physics/al363/sens/base
export MESA_INLIST=$MESA_BASE/inlist_main_low_O
export MESA_RUN=/work/al363/runs/low_overhead/runs_xfactor_number


#mkdir $MESA_BASE/runs_x100_1
cd $MESA_RUN

echo -e "the mesa run folder is $MESA_RUN\n" >> /hpc/group/physics/al363/sens/errors/xfactor_number._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err

shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line
let "index1=${SLURM_ARRAY_TASK_ID}*2"
let "index2=${index1}-1"

# Check for empty files using arrays
empty=false
test "$(ls -A ./${index2}/photos)"  && empty=false || empty=true

if $empty; then
    echo "starting from scratch "
    mkdir $MESA_RUN/${index2}
    cd $MESA_RUN/${index2}
    cat $MESA_BASE/inlist_cluster_templatefactor > ./inlist_cluster_low_overhead
    rxn1=$(sed -n ''${index2}'p' $MESA_BASE/reaction_list_305_10108.txt)
    sed -i 's|reaction_name1|'$rxn1'|g'  inlist_cluster_low_overhead
    rxn2=$(sed -n ''${index1}'p' $MESA_BASE/reaction_list_305_10108.txt)
    sed -i 's|reaction_name2|'$rxn2'|g'  inlist_cluster_low_overhead
    $MESA_BASE/star >> /hpc/group/physics/al363/sens/errors/xfactor_number._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err
else
    cd $MESA_RUN/${index2}
    if [! ls ./final_profile* 1> /dev/null 2>&1]; then
    	echo "this_model_is_finished"  >> /hpc/group/physics/al363/sens/errors/xfactor_number._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 
    else
    	echo "starting from photo" >> /hpc/group/physics/al363/sens/errors/xfactor_number._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 
    	cd ./photos
    	cp $(ls -t  | head -1) restart_photo
    	cd ../   #date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
    	if [[ -e star.exe ]];then
        	$MESA_BASE/star.exe
    	else
        	$MESA_BASE/star >> /hpc/group/physics/al363/sens/errors/xfactor_number._${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.err 
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


