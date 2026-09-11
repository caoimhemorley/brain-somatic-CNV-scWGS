# brain-somatic-CNV-scWGS

Processing and somatic copy-number variant (CNV) analysis of PicoPLEX-amplified single-nucleus whole-genome sequencing data from Parkinson’s disease and control human brain samples.

## Overview

This repository contains project-specific Bash workflows for processing single-nucleus whole-genome sequencing (snWGS) data generated from human brain tissue.

## Workflow

The analysis includes steps for:

* sequencing data preprocessing
* alignment to the human reference genome
* BAM processing and quality control
* single-nucleus sequencing quality assessment
* preparation of data for somatic CNV detection
* somatic CNV analysis and downstream filtering
* generation of summary statistics and analysis outputs

The exact workflow and parameters may evolve as the project develops.

## Software

The workflow consists primarily of Bash scripts that call established third-party bioinformatics tools.

Software requirements, versions, reference genome information, and tool-specific parameters will be documented as the workflow develops.

Third-party software remains subject to its respective licensing terms and is not distributed as part of this repository unless explicitly stated.

## Project status

This repository is under active development.

The current analysis focuses on Parkinson’s disease and control brain samples.

Workflow structure, analysis methods, and documentation may change as the project progresses.

## License

The project-specific scripts in this repository are released under the MIT License.

Third-party software and external tools used by the workflows remain subject to their respective licenses and terms of use.
