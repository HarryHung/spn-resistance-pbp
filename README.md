# PBP resistance predictor for S. pneumoniae

## About

### Purpose

This software is for the inference of beta-lactam resistance phenotype from the PBP genotype of Streptococcus pneumoniae.

### History

This is a fork of the [Pathogenwatch](https://pathogen.watch/)'s [Docker container](https://github.com/pathogenwatch-oss/spn-resistance-pbp) which is a modified version of [Ben Metcalfe's AMR predictor](https://github.com/BenJamesMetcalf/Spn_Scripts_Reference). Please credit the original authors in any resulting publication.

Pathogenwatch's Docker container is used as a Docker Executable Image. This version provides a Docker enviornment, which is designed for integrating into the [GPS Unified Pipeline](https://github.com/HarryHung/gps-unified-pipeline) (a Nextflow Pipeline for processing Streptococcus pneumoniae sequencing raw reads).

## Warning

We do not provide any support for the use or interpretation of this software, and it is provided on an "as-is" basis.

## Running the software

### Requirements

- [Docker](https://www.docker.com/)

### Building the Docker image

In the root directory of the repository run the following command:

```
docker build -t spn_pbp_amr .
```

### Running the software
When the built Docker image is set as the container of a Nextflow process, the software can be ran as following
```
spn_pbp_amr /path/to/assembly.fa > result.json
```
It will read the assembly from the provided path and output to `result.json`