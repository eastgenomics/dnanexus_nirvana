# eggd_nirvana

Based on https://github.com/Illumina/Nirvana/releases/tag/v2.0.10

## What does this app do?
This app runs Nirvana (v2.0.10) to annotate variants.

Nirvana provides clinical-grade annotation of genomic variants (SNVs, MNVs, insertions, deletions, indels, and SVs (including CNVs). It can be run as a stand-alone package or integrated into larger software tools that require variant annotation.

The input to Nirvana are VCFs and the output is a structured JSON representation of all annotation and sample information (as extracted from the VCF).

## What are typical use cases for this app?
This app should be executed stand-alone or as part of a DNAnexus workflow for a single sample.

## What data are required for this app to run?
The app requires a vcf file (.vcf) to run.

## What does this app output?
The app outputs a compressed JSON file (where [outPrefix] is the vcf filename without extension):

[outPrefix].json.gz - structured JSON representation of all annotation and sample information as extracted from the VCF

## How does this app work?
The app runs Nirvana using an input vcf file and uploads the output to DNAnexus.

## What are the limitations of this app
Where insertion/deletion differences exist betweeen a RefSeq transcript and the reference genome sequences, Nirvana 2.0.3 generates incorrect HGVS nomenclature for variants downstream of those differences.
