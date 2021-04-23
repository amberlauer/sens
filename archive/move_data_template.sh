#!/bin/bash

rsync -r runs_x100_number /datacommons/phy-champagne-lauer/
mkdir /datacommons/phy-champagne-lauer/runs_x100_number/errors
mv /work/al363/sens/errors/slurm._job_number* /datacommons/phy-champagne-lauer/runs_x100_number/errors/
