#!/bin/bash

echo "what is the round number?"
read number
echo "what's the multiplier

1. 100
2. .01
"
read mult
let "numero=${number}-1"
if [ "${mult}" = "1" ] ; then
        factor=100
        cp slurm_scavenger_10108_1b_template.q slurm_scavenger_10108_1b_${number}_${factor}.q
        sed -i 's|factor|'${factor}'|g'  slurm_scavenger_10108_1b_${number}_${factor}.q

elif [ "${mult}" = "2" ] ; then
        factor=.01
        cp slurm_scavenger_10108_1b_template.q slurm_scavenger_10108_1b_${number}_${factor}.q
        sed -i 's|factor|'${factor}'|g'  slurm_scavenger_10108_1b_${number}_${factor}.q
fi

sed -i 's|number|'${number}'|g'  slurm_scavenger_10108_1b_${number}_${factor}.q
sed -i 's|numero|'${numero}'|g'  slurm_scavenger_10108_1b_${number}_${factor}.q
rsync -r /datacommons/phy-champagne-lauer/runs_x${factor}_${number} /work/al363/runs/runs_x${factor}_${number}
#mkdir /work/al363/runs/runs_x${factor}_${number}/errors
sbatch slurm_scavenger_10108_1b_${number}_${factor}.q >> job_number_${number}_${factor}.txt

mv slurm_scavenger_10108_1b_${number}_${factor}.q /slurms
#### old junk that didn't work
#job_number=$(tail -c 9 job_number.txt)

#cp move_data_template.sh move_data_${number}.sh
#sed -i 's|number|'${number}'|g'   move_data_${number}.sh
#sed -i 's|job_number|'${job_number}'|g' move_data_${number}.sh
#sbatch --dependency=afterok:${job_number} move_data_${number}.sh


#rm job_number.txt
