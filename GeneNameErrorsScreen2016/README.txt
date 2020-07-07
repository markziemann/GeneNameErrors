Gene Names Error Screen - updated 2016-08-28
mark.ziemann@gmail.com

This folder contains source data and scripts that you can use to replicate my
work shown in the paper on the Excel gene names issue in supplementary data.
PMID: 27552985

These scripts work on Ubuntu 14.04 LTS and require specific dependancies:
ssconvert and gnu-parallel. These are easily installed using apt:
$sudo apt-get install gnumeric parallel

The subdirectories are organised by publishing house, with the exception of the
library of gene lists "genelists". The journal name has a suffix which refers
to the number of times the analysis was repeated.

   .
   |-bmc
   |---bmc_bioinfo3
   |---bmc_genomics3
   |---genomebiol3
   |-cshl
   |---g+d3
   |---gr3
   |---rna3
   |-genelists
   |-geo2
   |---batch1_GSE
   |-npg
   |---nat_genet3
   |---nature3
   |-oxford
   |---bioinfo3
   |---dnares3
   |---gbe3
   |---hmg3
   |---mbe3
   |---nar3
   |-plos
   |---plos_biol3
   |---plos_compbiol3
   |---plos_one4
   |-science
   |---science3

The genelists directory is required for querying whether Excel files contain 
gene lists, prior to screening for gene name errors. These were downloaded from
Ensembl Biomart. You probably shouldn't need to change anything in this 
directory.

The Contents of each journal directory

These directories contain similar files adapted to managing formats of each 
journal.

nav_gr.sh <== This script scrapes the journal site for XLS/XLSX files

gr_supp_data_list.txt <== This is the resulting list of Excel files

scan_supp_files.sh <== This script downloads, converts and identifies errors

scan_results.txt <== This is a detailed dump of the screen results

smry.sh <== This script summarises the screen results

For multi-disciplinary journals, you'll also find stuff relevant to filtering
for genomics papers specifically:

get_ncbi_papers3.sh <== Script to convert pubmed XML dump to list of DOIs

pubmed_result_doi.txt <== List of DOIs obtained from running the above

