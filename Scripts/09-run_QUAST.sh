#!/bin/bash

#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=QUAST_run
#SBATCH --partition=pshort_el8
#SBATCH --output=/data/users/skeane/assembly_annotation_course/logs/QUAST/QUAST_%A_%a.out
#SBATCH --error=/data/users/skeane/assembly_annotation_course/logs/QUAST/QUAST_%A_%a.err

CONTAINER="/containers/apptainer/quast_5.2.0.sif"
REFDIR=/data/courses/assembly-annotation-course/references

WORKDIR=/data/users/skeane/assembly_annotation_course
RAWDIR=${WORKDIR}/output/genome

OUTDIRREF0=${WORKDIR}/output/Quast/referenceless
OUTDIRREF=${WORKDIR}/output/Quast/referenced
mkdir -p "${OUTDIRREF0}" "${OUTDIRREF}"

#Main
module purge


echo "Running QUAST on  $FILE"
#Referenceless
apptainer exec --bind /data/ ${CONTAINER} quast.py  \
-o "${OUTDIRREF0}" \
"${RAWDIR}/Flye/assembly.fasta" \
"${RAWDIR}/LJA/assembly.fasta" \
"${RAWDIR}/HIFIASM/assembly.bp.p_ctg.fasta"

echo "QUAST referenceless finished"
#with a genome reference
apptainer exec --bind /data/ ${CONTAINER} quast.py  \
-o "$OUTDIRREF" \
-r "${REFDIR}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa" \
"${RAWDIR}/Flye/assembly.fasta" \
"${RAWDIR}/LJA/assembly.fasta" \
"${RAWDIR}/HIFIASM/assembly.bp.p_ctg.fasta"

echo "QUAST referenced finished"

#--subassemblies "${RAWDIR}/HIFIASM/*.fa" "${RAWDIR}/LJA/*/*.fasta" \
