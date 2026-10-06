#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=64G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=mummer_run
#SBATCH --partition=pshort_el8
#SBATCH --array=0-5
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/Mummer/Mummer_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/Mummer/Mummer_%A_%a.err

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/output/genome
FLYE_DIR="${RAWDIR}/Flye/assembly.fasta"
LJA_DIR="${RAWDIR}/LJA/assembly.fasta"
HIFI_DIR="${RAWDIR}/HIFIASM/assembly.bp.p_ctg.fasta"
OUT_DIR="${WORKDIR}/output/mummer"

REF_GENOME_DIR="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa"
REF_ANNO_DIR="/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.57.gff3"

mkdir -p ${OUT_DIR}
cd "${OUT_DIR}"

CONTAINER="/containers/apptainer/mummer4_gnuplot.sif"
#Choosing to go explicit then the tried and true since this was getting messy in the old way
#first three jobs has the reference genome go against the assemblies the rest is assembly vs assemblies
if [ "$SLURM_ARRAY_TASK_ID" -eq 0 ]; then
    Start=${REF_GENOME_DIR}
    Against=${FLYE_DIR}
    NAME="reference_vs_flye"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 1 ]; then
    Start=${REF_GENOME_DIR}
    Against=${LJA_DIR}
    NAME="reference_vs_lja"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 2 ]; then
    Start=${REF_GENOME_DIR}
    Against=${HIFI_DIR}
    NAME="reference_vs_hifi"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 3 ]; then
    Start=${FLYE_DIR}
    Against=${LJA_DIR}
    NAME="flye_vs_lja"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 4 ]; then
    Start=${HIFI_DIR}
    Against=${LJA_DIR}
    NAME="hifi_vs_lja"

elif [ "$SLURM_ARRAY_TASK_ID" -eq 5 ]; then
    Start=${FLYE_DIR}
    Against=${HIFI_DIR}
    NAME="flye_vs_hifi"

else
    echo "ERROR: Unexpected SLURM_ARRAY_TASK_ID: ${SLURM_ARRAY_TASK_ID}"
    exit 1

fi
echo "CREATING COMPARISONS"

echo "Reference: ${Start}"
echo "Query:     ${Against}"
echo "Output:    ${NAME}"
#comparing
apptainer exec  --bind /data/ ${CONTAINER} \
    nucmer -t ${SLURM_CPUS_PER_TASK} \
           --breaklen=1000 \
           --mincluster=1000 \
           -p "${NAME}" \
           "${Start}" "${Against}"
#Graph making
apptainer exec --bind /data/ ${CONTAINER} \
    mummerplot -R "${Start}" -Q "${Against}" \
               --filter -t png --large --layout --fat \
               -p "plot_${NAME}" "${NAME}.delta"

echo "Task ID ${SLURM_ARRAY_TASK_ID}: Finished generating plot"