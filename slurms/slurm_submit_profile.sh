#!/bin/bash

echo "what is the round number?"
read number
echo "what is the start number"
read numero

cp slurm_scavenger_10108_template.q slurm_scavenger_10108_${number}_01.q
sed -i 's|number|'${number}'|g'  slurm_scavenger_10108_${number}_01.q
sed -i 's|numero|'${numero}'|g'  slurm_scavenger_10108_${number}_01.q

mkdir /work/al363/sens2/base/runs_x.01_${number}
sbatch slurm_scavenger_10108_${number}_01.q >> job_number_${number}_01.txt

#job_number=$(tail -c 9 job_number.txt)

#cp move_data_template.sh move_data_${number}.sh
#sed -i 's|number|'${number}'|g'   move_data_${number}.sh
#sed -i 's|job_number|'${job_number}'|g' move_data_${number}.sh
#sbatch --dependency=afterok:${job_number} move_data_${number}.sh


#rm job_number.txt
