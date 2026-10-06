#!/bin/bash

#SBATCH --time=2-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=LJA_run
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/LJA/LJA_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/LJA/LJA_%A_%a.err

CONTAINER="/containers/apptainer/lja-0.2.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/data/Edi-0/ERR11437331.fastq.gz
OUTDIR=${WORKDIR}/output/genome/LJA
mkdir -p ${OUTDIR} 

FILE=(${RAWDIR})

#Counter
CFILES=$(ls ${RAWDIR}| wc -l)
echo "Found files"

#Main
module purge

echo "Running LJA assemblies on $FILE"

apptainer exec --bind /data/ ${CONTAINER} lja \
--reads "$FILE" \
-o "$OUTDIR"

echo "LJA finished"