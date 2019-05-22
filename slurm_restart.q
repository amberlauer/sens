
#!/bin/bash
#
#SBATCH --partition scavenger
#SBATCH --job-name=sensitivity
#SBATCH --output=res1.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2048
#SBATCH --array=1-100
#SBATCH --mail-type=END
#SBATCH --mail-user=amberlauer@gmail.com


export MESA_DIR=~/mesa10398
export MESASDK_ROOT=~/mesasdk_1_2018
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh
export MESA_BASE=~/sens/base
export MESA_INLIST=$MESA_BASE/inlist
export MESA_RUN=~/sens/runs


shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line

folder=$MESA_RUN/${SLURM_ARRAY_TASK_ID}
    #for user file names
 #[[ $# -eq 0 ]] && { echo "Usage: $0 dir-name"; exit 1; }

 # Check for empty files using arrays
chk_files=($folder/*)
(( ${#chk_files[*]} )) && empty=true  || empty=false # Unset the variable for bash b$
if $empty; then

    echo "starting from scratch"
     mkdir $MESA_RUN/${SLURM_ARRAY_TASK_ID}
    cd $MESA_RUN/${SLURM_ARRAY_TASK_ID}
    ./rn
else
    echo "starting from photo"  
    cd $MESA_RUN/${SLURM_ARRAY_TASK_ID}
    cd ./photos
    cp $(ls -t  | head -1) restart_photo
    cd ../   date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
    if [[ -e star.exe ]];then
        ./star.exe
    else
       ./star  
    fi
    date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
fi


cat $MESA_BASE/inlist_cluster >./inlist_cluster
rxn=$(sed -n ${SLURM_ARRAY_TASK_ID}p ~/sens/reaction_list_305.txt)

sed -i "s|reaction_name|$rxn|g"  inlist_cluster

#Run Mesa
$MESA_BASE/star

srun hostname
srun sleep 60

shopt -u nullglob
shopt -u dotglob


1
