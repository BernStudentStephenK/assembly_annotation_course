#!/bin/bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Trinity_run
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Trinity/Trinity_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Trinity/Trinity_%A_%a.err

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/data/RNAseq_Sha/
OUTDIR=${WORKDIR}/output/transciption/Trinity
mkdir -p ${OUTDIR} 
cd ${OUTDIR}
#Counter for paired-end RNASEQ files
LEFT=$(ls "${RAWDIR}"/*_1.fastq.gz | paste -sd,)
RIGHT=$(ls "${RAWDIR}"/*_2.fastq.gz | paste -sd,)

#Main
#Trinity needs to be loaded specifically
module purge
module load Trinity

echo "LEFT read: $LEFT"
echo "Right reads: $RIGHT"

Trinity \
    --seqType fq \
    --left "$LEFT" \
    --right "$RIGHT" \
    --max_memory 64G \
    --CPU "$SLURM_CPUS_PER_TASK" \
    --output "$OUTDIR"


echo "TRINITY finished"