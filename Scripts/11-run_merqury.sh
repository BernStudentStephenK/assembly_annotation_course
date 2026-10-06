#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=merq_run
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Merq/Merq_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Merq/Merq_%A_%a.err

export MERQURY="/usr/local/share/merqury"
CONTAINER="/containers/apptainer/merqury_1.3.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
MERYLDIR=${WORKDIR}/output/meryl
RAWDIR=${WORKDIR}/output/genome
OUTDIR=${WORKDIR}/output/merqury
mkdir -p ${OUTDIR} 


FILES=("${RAWDIR}"/*/*.fasta)

Counter
CFILES=${#FILES[@]}
echo "Found ${CFILES} fasta files"

Job Runner
if [ -z "$SLURM_ARRAY_TASK_ID" ]; 
then
  echo "Running"
  sbatch --array=0-$(($CFILES - 1)) $0
  exit 0
fi
#post runner setup
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
ASSEMBLY_NAME=$(basename "$(dirname "${FILE}")")
echo ${ASSEMBLY_NAME}

#Main
module purge

#required tto make the directory before going in
OUTFILEDIR="${OUTDIR}/${ASSEMBLY_NAME}" 
mkdir -p "${OUTFILEDIR}"
cd "${OUTFILEDIR}" || exit 1


echo "Running Merqury on Assembly"

apptainer exec --bind /data/ --env MERQURY="/usr/local/share/merqury" ${CONTAINER} /usr/local/share/merqury/merqury.sh \
  "${MERYLDIR}/reads.meryl" \
  "${FILE}" \
  "${ASSEMBLY_NAME}"
  


echo "Merqury finished for this"