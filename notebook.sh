#!/bin/bash

#SBATCH --job-name=notebook                                             	# Job name
#SBATCH --ntasks=1                                                      	# Number of tasks
#SBATCH --cpus-per-task=8                                               	# Number of CPU cores per task
#SBATCH --nodes=1                                                       	# Ensure that all cores are on the same machine with nodes=1
#SBATCH --partition=a100-galvani                                        	# Which partition will run your job
#SBATCH --time=0-01:00                                                  	# Allowed runtime in D-HH:MM
#SBATCH --gres=gpu:1                                                    	# (optional) Requesting type and number of GPUs
#SBATCH --mem=32G                                                       	# Total memory pool for all cores (see also --mem-per-cpu); exceeding this number will cause your job to fail.
#SBATCH --output=/mnt/lustre/work/<prof-name>/<your-id>/logs/myjob-%j.out       # File to which STDOUT will be written - make sure this is not on $HOME
#SBATCH --error=/mnt/lustre/work/<prof-name>/<your-id>/logs/myjob-%j.err        # File to which STDERR will be written - make sure this is not on $HOME
#SBATCH --mail-type=ALL                                                 	# Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=<your-email>                   				# Email to which notifications will be sent

cd $WORK/<repo> && source .venv/bin/activate && jupyter-lab --no-browser --port 8080
