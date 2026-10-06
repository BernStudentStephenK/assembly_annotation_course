#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=Meryl_run
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Meryl/Meryl_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Meryl/Meryl_%A_%a.err

CONTAINER="/containers/apptainer/merqury_1.3.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
DATADIR=${WORKDIR}/data/Edi-0/ERR11437331.fastq.gz
OUTDIR=${WORKDIR}/output/meryl
mkdir -p ${OUTDIR} 



#Main
module purge

#Creating meryl db for merqury 
if [ ! -d "${OUTDIR}/reads.meryl" ]; then

  apptainer exec --bind /data/ ${CONTAINER} meryl \
    count k=21 \
    output "${OUTDIR}/reads.meryl" \
    ${DATADIR}
    
fi

echo "Meryl database finished"