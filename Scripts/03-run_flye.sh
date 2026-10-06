#!/bin/bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=flye_run
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Flye/Flye_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Flye/Flye_%A_%a.err

CONTAINER="/containers/apptainer/flye_2.9.5.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/data/Edi-0/ERR11437331.fastq.gz
OUTDIR=${WORKDIR}/output/genome/Flye
mkdir -p ${OUTDIR} 

#setup
FILES=(${RAWDIR})
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

#Counter
CFILES=$(ls ${RAWDIR}| wc -l)
echo "Found files"

#Job Runner
if [ -z "$SLURM_ARRAY_TASK_ID" ]; 
then
  echo "Running"
  sbatch --array=0-$(($CFILES - 1)) $0
  exit 0
fi

#Main
module purge

echo "Running Flye assemblies on $FILE"

apptainer exec --bind /data/ ${CONTAINER} flye --pacbio-hifi "$FILE" -o ${OUTDIR} --threads 16

echo " Flye assemblies FINISHED on $FILE"
