
#!/bin/bash
#
#SBATCH --partition scavenger
#SBATCH --job-name=sensitivity
#SBATCH --output=res1.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=2048
#SBATCH --array=1-10
#SBATCH --mail-type=END
#SBATCH --mail-user=amberlauer@gmail.com

export MESA_DIR=/dscrhome/al363/mesa10398
export MESASDK_ROOT=/dscrhome/al363/mesasdk_1_2018
#export MESASDK_ROOT=/dscrhome/al363/mesasdk_8_18
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh
export MESA_BASE=/dscrhome/al363/sens/base
export MESA_INLIST=$MESA_BASE/inlist
export MESA_RUN=$MESA_BASE/runs


cd $MESA_RUNS

shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line

# Check for empty files using arrays
chk_files=($folder/*)
(( ${#chk_files[*]} )) && empty=true  || empty=false # Unset the variable for bash b$
if $empty; then
    echo "starting from scratch"
    mkdir $MESA_RUN/${SLURM_ARRAY_TASK_ID}
    cd $MESA_RUN/${SLURM_ARRAY_TASK_ID}
    cat $MESA_BASE/inlist_cluster >./inlist_cluster
    rxn=$(sed -n ''${SLURM_ARRAY_TASK_ID}'p' $MESA_BASE/reaction_list_305.txt)
    sed -i 's|reaction_name|'$rxn'|g' inlist_cluster

    $MESA_BASE/star
else
    echo "starting from photo"  
    cd $MESA_RUN/${SLURM_ARRAY_TASK_ID}
    cd ./photos
    cp $(ls -t  | head -1) restart_photo
    cd ../   date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
    if [[ -e star.exe ]];then
        $MESA_BASE/star.exe
    else
       $MESA_BASE/star  
    fi
    date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
fi


#Run Mesa
$MESA_BASE/star

#srun hostname
#srun sleep 60

shopt -u nullglob
shopt -u dotglob

done

