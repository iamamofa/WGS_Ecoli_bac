#!/bin/bash
#SBATCH --job-name=Ecoli_WGS
#SBATCH --output=logs/wgs_%A_%a.out
#SBATCH --error=logs/wgs_%A_%a.err
#SBATCH --array=1-100
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00

# ------------------ ENVIRONMENT SETUP ------------------
module load fastqc multiqc fastp kraken2 spades quast checkm prokka \
             bwa samtools freebayes roary mafft iqtree amrfinder abricate \
             mob_suite ectyper R

# ------------------ PATHS ------------------
DATA_DIR="Data"
RESULTS_DIR="results"
REF="/path/to/reference.fasta"
KRAKEN_DB="/path/to/kraken2_db"
mkdir -p logs ${RESULTS_DIR}/{fastqc,trimmed,kraken,assembly,quast,checkm,prokka,alignment,variants,pangenome,phylogeny,amr,vf,plasmid,serotype}

# ------------------ SAMPLE SELECTION ------------------
R1_FILES=(${DATA_DIR}/*_R1.fastq.gz)
R1_FILE=${R1_FILES[$SLURM_ARRAY_TASK_ID-1]}
R2_FILE=${R1_FILE/_R1/_R2}
SAMPLE=$(basename "$R1_FILE" | cut -d_ -f1,2)

echo "[$(date)] Starting analysis for ${SAMPLE}"
echo "Input files: $R1_FILE and $R2_FILE"

# ------------------ 1. QUALITY CONTROL ------------------
fastqc "$R1_FILE" "$R2_FILE" -o ${RESULTS_DIR}/fastqc/
multiqc ${RESULTS_DIR}/fastqc/ -o ${RESULTS_DIR}/fastqc/

# ------------------ 2. TRIMMING ------------------
fastp \
    -i "$R1_FILE" -I "$R2_FILE" \
    -o ${RESULTS_DIR}/trimmed/${SAMPLE}_R1_trim.fastq.gz \
    -O ${RESULTS_DIR}/trimmed/${SAMPLE}_R2_trim.fastq.gz \
    --thread "$SLURM_CPUS_PER_TASK"

R1_TRIM=${RESULTS_DIR}/trimmed/${SAMPLE}_R1_trim.fastq.gz
R2_TRIM=${RESULTS_DIR}/trimmed/${SAMPLE}_R2_trim.fastq.gz

# ------------------ 3. CONTAMINATION SCREENING ------------------
kraken2 --db $KRAKEN_DB --threads $SLURM_CPUS_PER_TASK \
        --gzip-compressed --output ${RESULTS_DIR}/kraken/${SAMPLE}.kraken \
        --report ${RESULTS_DIR}/kraken/${SAMPLE}.report \
        "$R1_TRIM" "$R2_TRIM"

# ------------------ 4. DE NOVO ASSEMBLY ------------------
ASSEMBLY_DIR=${RESULTS_DIR}/assembly/${SAMPLE}
mkdir -p "$ASSEMBLY_DIR"
spades.py -1 "$R1_TRIM" -2 "$R2_TRIM" -t $SLURM_CPUS_PER_TASK -o "$ASSEMBLY_DIR"

ASSEMBLY=${ASSEMBLY_DIR}/contigs.fasta

# ------------------ 5. ASSEMBLY QC ------------------
quast "$ASSEMBLY" -o ${RESULTS_DIR}/quast/${SAMPLE}
checkm lineage_wf -t $SLURM_CPUS_PER_TASK -x fasta \
       "$ASSEMBLY_DIR" ${RESULTS_DIR}/checkm/${SAMPLE}

# ------------------ 6. ANNOTATION ------------------
PROKKA_DIR=${RESULTS_DIR}/prokka/${SAMPLE}
prokka "$ASSEMBLY" --outdir "$PROKKA_DIR" --prefix "$SAMPLE" --cpus $SLURM_CPUS_PER_TASK

# ------------------ 7. REFERENCE MAPPING ------------------
bwa mem "$REF" "$R1_TRIM" "$R2_TRIM" > ${RESULTS_DIR}/alignment/${SAMPLE}.sam
samtools view -bS ${RESULTS_DIR}/alignment/${SAMPLE}.sam > ${RESULTS_DIR}/alignment/${SAMPLE}.bam
samtools sort ${RESULTS_DIR}/alignment/${SAMPLE}.bam -o ${RESULTS_DIR}/alignment/${SAMPLE}_sorted.bam
samtools index ${RESULTS_DIR}/alignment/${SAMPLE}_sorted.bam

# ------------------ 8. VARIANT CALLING ------------------
freebayes -f "$REF" ${RESULTS_DIR}/alignment/${SAMPLE}_sorted.bam > ${RESULTS_DIR}/variants/${SAMPLE}.vcf

# ------------------ 9. AMR GENE DETECTION ------------------
amrfinder -n "$ASSEMBLY" -O results/amr/${SAMPLE}

# ------------------ 10. VIRULENCE FACTORS ------------------
abricate --db vfdb "$ASSEMBLY" > ${RESULTS_DIR}/vf/${SAMPLE}_vf.tsv

# ------------------ 11. PLASMID & MOB TYPING ------------------
mob_suite typestrain "$ASSEMBLY" -o ${RESULTS_DIR}/plasmid/${SAMPLE}

# ------------------ 12. SEROTYPING ------------------
ectyper "$ASSEMBLY" > ${RESULTS_DIR}/serotype/${SAMPLE}_serotype.tsv

# ------------------ SUMMARY ------------------
echo "[$(date)] Completed WGS workflow for ${SAMPLE}"
