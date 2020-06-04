#!/bin/bash
#SBATCH --partition scavenger
#SBATCH --job-name=special_19_12_12_add_back_2_TP
#SBATCH --output=/work/al363/sens2/19_12_12_add_back_2_TP/output.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=3072
#SBATCH --array=1
#SBATCH --mail-type=END
#SBATCH --mail-user=amberlauer@gmail.com
#SBATCH -e /work/al363/sens2/19_12_12_add_back_2_TP/output.txt

export MESA_DIR=/hpc/group/physics/al363/mesa12115
export MESASDK_ROOT=/hpc/group/physics/al363/mesasdk_8_19
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
source $MESASDK_ROOT/bin/mesasdk_init.sh

#mkdir $MESA_BASE/runs_x100_number
#cd $MESA_RUN

shopt -s nullglob
shopt -s dotglob # Die if dir name provided on command line
#let "index1=${SLURM_ARRAY_TASK_ID}*2"
#let "index2=${index1}-1"

# Check for empty files using arrays
empty=false
test "$(ls -A ./19_12_12_add_back_2_TP/photos)" || empty=true
cd /work/al363/sens2/19_12_12_add_back_2_TP
echo "mesa version is" $MESA_DIR>> output.txt
echo "sdk version is"  $MESASDK_ROOT >> output.txt
./clean
./mk
if $empty; then
    echo "starting from scratch "
    ./rn >> output.txt
else
        cd ./photos
        cp $(ls -t  | head -1) restart_photo
        cd ../   date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
        if [[ -e star.exe ]];then
        ./star.exe
        else
        ./star >> /work/al363/sens2/19_12_12_add_back_2_TP/output.txt
        fi
        date "+DATE: %Y-%m-%d%nTIME: %H:%M:%S"
fi



#srun hostname
#srun sleep 60






