# WGS_Ecoli_bac
#  Automated Whole-Genome Sequencing Analysis Pipeline

## 📖 Pipeline Overview

**Ecoli_WGS** is a modular, SLURM-compatible workflow for *Escherichia coli* whole-genome sequencing (WGS) analysis.  
It automates every step — from raw FASTQ files to annotated assemblies, phylogenetic trees, and antimicrobial resistance profiling.

### 🔬 Features

- Quality control and trimming  
- Contamination screening  
- *De novo* assembly and quality assessment  
- Genome annotation  
- Reference mapping and variant calling  
- Pangenome & core-genome analysis  
- Phylogeny reconstruction  
- AMR, virulence, plasmid, and serotype typing  
- Automated visualization and summary reporting  

---

## 📦 Repository Layout

```text
Ecoli_WGS/
├── README.md
├── ecoli_wgs_env.yml                  # Conda environment for all dependencies
├── scripts/
│   ├── 01_qc.sh                      # FastQC + MultiQC
│   ├── 02_trim.sh                    # fastp trimming
│   ├── 03_kraken.sh                  # Kraken2 contamination check
│   ├── 04_assembly.sh                # SPAdes assembly
│   ├── 05_quast_checkm.sh            # Assembly QC
│   ├── 06_prokka.sh                  # Genome annotation
│   ├── 07_mapping.sh                 # BWA mapping
│   ├── 08_variants.sh                # FreeBayes variant calling
│   ├── 09_pangenome.sh               # Roary pangenome
│   ├── 10_core_alignment.sh          # MAFFT core alignment
│   ├── 11_phylogeny.sh               # IQ-TREE phylogeny
│   ├── 12_amr.sh                     # AMRFinderPlus
│   ├── 13_vf.sh                      # ABRicate VFDB
│   ├── 14_plasmid.sh                  # MOB-suite typing
│   ├── 15_serotype.sh                # ECTyper serotyping
│   └── 16_visualization.sh           # R visualization
├── ecoli_wgs_pipeline.slurm          # SLURM job array script
├── wgs_postproc.slurm                # Post-processing (pangenome/phylogeny)
├── sample_data/                      # Example FASTQ inputs
├── results/                          # Output directories (auto-created)
└── logs/                             # SLURM log files
```

---

## 🚀 Getting Started

### 1️⃣ Installation Setup

#### 🧩 Conda Environment (Recommended)

Create and activate the environment:
```bash
conda env create -f ecoli_wgs_env.yml
conda activate ecoli_wgs
```markdown
# Ecoli_WGS Pipeline

## 📦 Installed Tools

**QC tools:**
fastqc, multiqc, fastp

**Assembly tools:**
spades, quast, checkm-genome

**Annotation:**
prokka

**Mapping & variants:**
bwa, samtools, freebayes

**Comparative genomics:**
roary, mafft, iqtree

**Typing:**
amrfinderplus, abricate, mob_suite, ectyper

**Visualization:**
R, ggplot2, itolapi, phandango

---

## 📦 Databases Setup

```bash
kraken2-build --standard --db /path/to/kraken2_db
checkm data setRoot /path/to/checkm_db
amrfinder_update
```

---

## 2️⃣ Data Preparation

Place your FASTQ files in the `Data/` or `sample_data/` folder:

```text
sample_data/
├── sample1_R1.fastq.gz
├── sample1_R2.fastq.gz
├── sample2_R1.fastq.gz
└── sample2_R2.fastq.gz
```

---

## 3️⃣ SLURM Configuration

Edit key parameters in the main SLURM script (`ecoli_wgs_pipeline.slurm`):

```bash
#SBATCH --array=1-100
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=24:00:00
DATA_DIR="Data"
REF="/path/to/reference.fasta"
KRAKEN_DB="/path/to/kraken2_db"
```

---

## 4️⃣ Run the Pipeline

Submit the main array job:

```bash
sbatch ecoli_wgs_pipeline.slurm
```

After all jobs finish, run the post-processing:

```bash
sbatch --dependency=afterok:<JOBID> wgs_postproc.slurm
```

---

## ⚙️ Pipeline Modules

| Module                | Description                                      |
|-----------------------|--------------------------------------------------|
| 01_qc.sh              | FastQC + MultiQC quality control                 |
| 02_trim.sh            | fastp trimming                                   |
| 03_kraken.sh          | Kraken2 contamination screening                  |
| 04_assembly.sh        | De novo assembly with SPAdes                      |
| 05_quast_checkm.sh    | QUAST + CheckM assembly QC                       |
| 06_prokka.sh          | Annotation using Prokka                          |
| 07_mapping.sh         | Reference mapping (BWA + Samtools)               |
| 08_variants.sh        | Variant calling with FreeBayes                   |
| 09_pangenome.sh       | Pangenome analysis with Roary                    |
| 10_core_alignment.sh  | Core alignment (MAFFT)                           |
| 11_phylogeny.sh       | Phylogeny inference (IQ-TREE)                    |
| 12_amr.sh             | AMR detection (AMRFinderPlus)                    |
| 13_vf.sh              | Virulence gene screening (ABRicate + VFDB)       |
| 14_plasmid.sh         | MOB-suite plasmid typing                         |
| 15_serotype.sh        | Serotyping with ECTyper                          |
| 16_visualization.sh   | Visualization & reporting in R                   |

---

## 📂 Outputs

| Output Folder         | Contents                                 |
|-----------------------|------------------------------------------|
| results/fastqc/       | QC reports                               |
| results/trimmed/      | Trimmed FASTQ files                      |
| results/kraken/       | Contamination reports                    |
| results/assembly/     | SPAdes assemblies                        |
| results/quast/        | Assembly metrics                         |
| results/checkm/       | Completeness checks                      |
| results/prokka/       | Annotated genomes                         |
| results/alignment/    | BAM alignments                            |
| results/variants/     | VCF files                                 |
| results/pangenome/    | Roary core/pan-genomes                   |
| results/phylogeny/    | Phylogenetic trees                       |
| results/amr/          | AMR gene detections                      |
| results/vf/           | Virulence factors                         |
| results/plasmid/      | MOB-suite plasmid reports                 |
| results/serotype/     | ECTyper results                           |
| results/visuals/      | Tree visualizations (iTOL/Phandango)     |

---

## 🧪 Testing & Validation

- Test on small datasets (2–3 E. coli isolates).
- Inspect QC (FastQC/MultiQC) before trimming.
- Validate assembly and annotation quality using QUAST & CheckM.
- Confirm AMR and virulence gene predictions against known data.

---

## 📝 Notes

- Requires SLURM job scheduler.
- Databases for Kraken2, AMRFinderPlus, CheckM, and VFDB must be installed before use.
- Compatible with both Conda and Mamba environments.
- Post-processing steps (pangenome/phylogeny) should be run after all assemblies are complete.

---

## 💬 Contact & Support

**Maintainer:**
Justice Ohene Amofa
📧 [justiceoheneamofa@gmail.com](mailto\:justiceoheneamofa@gmail.com)
🏛️ Noguchi Memorial Institute for Medical Research (NMIMR), Accra, Ghana

---

## 📚 References

| Tool         | Citation                                                                 |
|--------------|--------------------------------------------------------------------------|
| FastQC       | Andrews, S. (2010). FastQC: A Quality Control Tool for High Throughput Sequence Data. |
| MultiQC      | Ewels et al. (2016). Bioinformatics, 32(19): 3047–3048.                |
| fastp        | Chen et al. (2018). Bioinformatics, 34(17): i884–i890.                 |
| Kraken2      | Wood et al. (2019). Genome Biology, 20(1): 257.                         |
| SPAdes       | Bankevich et al. (2012). J Comput Biol, 19(5): 455–477.                  |
| QUAST        | Gurevich et al. (2013). Bioinformatics, 29(8): 1072–1075.               |
| CheckM       | Parks et al. (2015). Genome Res, 25(7): 1043–1055.                     |
| Prokka       | Seemann, T. (2014). Bioinformatics, 30(14): 2068–2069.                  |
| BWA          | Li, H., & Durbin, R. (2009). Bioinformatics, 25(14): 1754–1760.         |
| FreeBayes    | Garrison, E., & Marth, G. (2012). arXiv:1207.3907.                      |
| Roary        | Page et al. (2015). Bioinformatics, 31(22): 3691–3693.                  |
| MAFFT        | Katoh et al. (2002). Nucleic Acids Res, 30(14): 3059–3066.               |
| IQ-TREE      | Nguyen et al. (2015). Mol Biol Evol, 32(1): 268–274.                   |
| AMRFinderPlus| Feldgarden et al. (2019). Antimicrob Agents Chemother, 63(11): e00483–19.|
| ABRicate     | Seemann, T. (github.com/tseemann/abricate)                             |
| MOB-suite    | Robertson et al. (2018). Nucleic Acids Res, 46(14): 7777–7789.           |
| ECTyper      | Zhang et al. (2019). J Clin Microbiol, 57(10): e01206–19.              |

---

## 🌟 Future Plans

- Integration with Nextflow DSL2
- Addition of Docker/Singularity container profiles
- Automated Rmarkdown summary reporting
- Continuous integration testing (GitHub Actions)

---

## 🧠 About

Ecoli_WGS is a modular, scalable, and reproducible workflow for bacterial genomics.
It enables automated E. coli WGS analysis — from quality control to high-resolution phylogeny — for both research and surveillance applications.

© 2025 Justice Ohene Amofa · Noguchi Memorial Institute for Medical Research

---

### ✅ Instructions

- Save this text as `README.md` in your repository root.
- GitHub will render it with all headers, tables, emojis, and formatting automatically.

---
```
