
#!/bin/bash



export MESA_DIR=~/mesa10398
export MESASDK_ROOT=~/mesasdk_1_2018
#sexport OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh
export MESA_BASE=~/sens/base
export MESA_INLIST=$MESA_BASE/$inlist
export MESA_RUN=~/sens/runs


shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line
for i in {1..10}
do

    #for user file names
 #[[ $# -eq 0 ]] && { echo "Usage: $0 dir-name"; exit 1; }

 # Check for empty files using arrays
chk_files=($folder/*)
(( ${#chk_files[*]} )) && empty=true  || empty=false # Unset the variable for bash b$
if $empty; then
    echo "starting from scratch"
     mkdir $MESA_RUN/$i
    cd $MESA_RUN/$i
    cat $MESA_BASE/$inlist_cluster >./$inlist_cluster
    rxn=$(sed -n 1p ~/sens/reaction_list_305.txt)
    sed -i "s|reaction_name|$rxn|g"  inlist_cluster

    $MESA_BASE/star
else
    echo "starting from photo"  
    cd $MESA_RUN/$i
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

srun hostname
srun sleep 60

shopt -u nullglob
shopt -u dotglob

done
1
