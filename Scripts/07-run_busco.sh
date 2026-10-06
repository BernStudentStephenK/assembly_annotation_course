#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=Busco_run
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Busco/Busco_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Busco/Busco_%A_%a.err

CONTAINER="/containers/apptainer/busco_5.7.1.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/output/genome
OUTDIR=${WORKDIR}/output/Busco
mkdir -p ${OUTDIR}
#Required to change directory or else busco will download busco_downloads to your script folder 
cd ${OUTDIR}

GFILES=(${RAWDIR}/*/*.fasta)
FILE=${GFILES[$SLURM_ARRAY_TASK_ID]}

#Counter
CFILES=$(ls ${RAWDIR}/*/*.fasta| wc -l)
echo "Found fasta $CFILES files"

if [ -z "$SLURM_ARRAY_TASK_ID" ]; 
then
  echo "Running"
  sbatch --array=0-$(($CFILES - 1)) $0
  exit 0
fi

ASSEMBLY_NAME=$(basename "$(dirname "${FILE}")")
#Main
module purge

#QOL logging
echo "Running Busco on Genome $FILE"

echo "FILE = ${FILE}"
echo "ASSEMBLY_NAME = ${ASSEMBLY_NAME}"
echo "OUTDIR = ${OUTDIR}"
echo "SLURM_CPUS_PER_TASK = ${SLURM_CPUS_PER_TASK}"


apptainer exec --bind /data/ ${CONTAINER} busco --cpu "${SLURM_CPUS_PER_TASK}" \
-i "${FILE}" \
-m "genome" \
-l "brassicales_odb10" \
-o "${ASSEMBLY_NAME}" \
-f \
--out_path "${OUTDIR}"


echo "Genome Bosco finished"
