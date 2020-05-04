<!-- dx-header -->
This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://documentation.dnanexus.com/.
<!-- /dx-header -->

# dnanexus_nirvana_2.0.10 (https://github.com/Illumina/Nirvana/releases/tag/v2.0.10)

## What does this app do?
This app runs Illumina's Nirvana 2.0.10 to annotate variants.

Nirvana provides clinical-grade annotation of genomic variants (SNVs, MNVs, insertions, deletions, indels, and SVs (including CNVs). It can be run as a stand-alone package or integrated into larger software tools that require variant annotation.

The input to Nirvana are VCFs and the output is a structured JSON representation of all annotation and sample information (as extracted from the VCF).

Backronym: NImble and Robust VAriant aNnotAtor 

Annotation data is stored outside the app and downloaded to the instance from the Refs project when the app is run.

## What are typical use cases for this app?
This app should be executed stand-alone or as part of a DNAnexus workflow for a single sample.

## What data are required for this app to run?
The app requires a VCF file (.vcf) and access to the project containing the annotation data to run.

## What does this app output?
The app outputs one file, where [outPrefix] is the vcf filename without extension:
1. [outPrefix].json.gz - Annotation for variants present within the input vcf (gzipped json file)

## How does this app work?
The app runs Nirvana 2.0.10 using an input VCF file and uploads the output to DNAnexus.

## What are the limitations of this app
- Only features present in the annotation data will be annotated against variants. i.e. if a transcript is not present within the annotation data then it will be absent from the annotation of variants within that transcript

## This app was made by EMEE GLH
