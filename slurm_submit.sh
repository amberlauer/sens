#!/bin/bash

echo "what is the round number?"
read number
numero=$((number-1))
echo "numero is "${number}
echo "what factor?
1: 100
2: .01"
read varr
if [ "${varr}" = "1" ] ; then
	factor=100
elif [ "${varr}" = "2" ]; then
        factor=.01
fi
cp slurm_scavenger_10108_template.q slurm_scavenger_10108_${number}.q
sed -i 's|number|'${number}'|g'  slurm_scavenger_10108_${number}.q
sed -i 's|numero|'${numero}'|g'  slurm_scavenger_10108_${number}.q
sed -i 's|factor|'${factor}'|g'  slurm_scavenger_10108_${number}.q 
mkdir /work/al363/new_sens/base/runs_x${factor}_${number}
sbatch slurm_scavenger_10108_${number}.q >> job_number.txt
mv slurm_scavenger_10108_${number}.q >> /work/al363/new_sens/base/runs_x${factor}_${number}

#cp move_data_template.sh move_data_${number}.sh
#sed -i 's|number|'${number}'|g'   move_data_${number}.sh
#sed -i 's|job_number|'${job_number}'|g' move_data_${number}.sh
#sbatch --dependency=afterok:${job_number} move_data_${number}.sh


#rm job_number.txt
