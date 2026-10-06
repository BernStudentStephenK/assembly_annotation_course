#!/bin/bash

#SBATCH --time=1-00:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Hifi_run
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/HIFI/HIFI_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/HIFI/HIFI_%A_%a.err

CONTAINER="/containers/apptainer/hifiasm_0.25.0.sif"

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/data/Edi-0/ERR11437331.fastq.gz
OUTDIR=${WORKDIR}/output/genome/HIFIASM
mkdir -p ${OUTDIR} 

FILE=(${RAWDIR})

#Counter
CFILES=$(ls ${RAWDIR}| wc -l)
echo "Found files"

#Main
module purge

echo "Running Flye assemblies on $FILE"

apptainer exec --bind /data/ ${CONTAINER} hifiasm -t "${SLURM_CPUS_PER_TASK}"  \
-o "${OUTDIR}/assembly" \
"$FILE" 


echo "Hifiasm finished"
#conversion to something that works
awk '/^S/{print ">"$2;print $3}' \
    "${OUTDIR}/assembly.bp.p_ctg.gfa" \
    > "${OUTDIR}/assembly.bp.p_ctg.fasta"

echo "GFA converted to FASTA"
echo "Hifiasm assembly FINISHED"