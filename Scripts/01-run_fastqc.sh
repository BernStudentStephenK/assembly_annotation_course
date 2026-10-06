#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=fastqc_run
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/fastQC/fastqc_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/fastQC/fastqc_%A_%a.err

#Directories and container
CONTAINER=/containers/apptainer/fastqc-0.12.1.sif

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/data/
OUTDIR=${WORKDIR}/output/fastqc
mkdir -p ${OUTDIR}

#Good old find pair read fasta files
FILES=$(find "$RAWDIR" -type f -name "*.fasta")
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

#Counter for counting the fasta files
CFILES=$(find "$RAWDIR" -type f -name "*.fasta" | wc -l)
echo "Found files"

#Job Runner instead of doing the bash array automatic is good 
if [ -z "$SLURM_ARRAY_TASK_ID" ]; 
then
  echo "Running"
  sbatch --array=0-$(($CFILES - 1)) $0
  exit 0
fi

#Main 
#for consistency
module purge


echo "Running FastQC on $FILE"
apptainer exec --bind /data/ ${CONTAINER} fastqc "$FILE" -o ${OUTDIR}

echo "FastQC completed for $FILE"