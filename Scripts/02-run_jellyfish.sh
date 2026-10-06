#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=jelly_run
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Jellyfish/Jelly_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Jellyfish/Jelly_%A_%a.err

CONTAINER="/containers/apptainer/jellyfish-2.2.6--0.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/data/Edi-0/ERR11437331.fastq.gz
OUTDIR=${WORKDIR}/output/Jellyfish
OUT_KMER=${OUTDIR}/k_mer_counts.jf
OUT_HIST=${OUTDIR}/readss.histo
mkdir -p ${OUTDIR} 

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
#Can be either 31 or 21 or any other number the idea is those two numbers are generally the best
#Also zcat is necessary since jellyfish can't open zip files on its own
apptainer exec --bind /data/ ${CONTAINER} jellyfish count \
    -C -m 31 \
    -s 5G \
    -t $SLURM_CPUS_PER_TASK \
    -o ${OUT_KMER} \
    <(zcat ${RAWDIR}) 

#Histogram pushing the kmer results into kmer easy
apptainer exec --bind /data/ ${CONTAINER} jellyfish histo -t $SLURM_CPUS_PER_TASK "${OUT_KMER}" > "${OUT_HIST}"