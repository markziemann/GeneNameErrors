#!/bin/bash
#Debug:off
set -x

# GetNcbiPapers: Get a list of papers from the journal
# Screen the papers for presence of xls supplementary files
# Written by Mark Ziemann mark.ziemann@gmail.com Jan2016

# Input file: go to NCBI pubmed, perform an advanced search based on
# Journal name and date of publication
# search:
#((("Nature"[Journal]) AND genome[Title/Abstract])) AND ("2005"[Date - Publication] : "2015"[Date - Publication])
# save the xml as the following:
PUBMED_RES=pubmed_result.xml

# Input file: go to NCBI pubmed, perform an advanced search based on
# Journal name and date of publication
DOI_LIST=pubmed_result_doi.txt

# Output file is a list of URLS that point to supplementary XLS files
SUPPFILELIST=supp_file_urls.txt

# Empty the output file
>supp_file_urls.txt

# Extract DOIs from the xml then scrape fulltext for xls files
XML_QUERY="PubmedArticleSet/PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType='doi']"
xmlstarlet sel -t -v $XML_QUERY pubmed_result.xml > $DOI_LIST

for DOI in $(cat $DOI_LIST) ; do
  sleep 1
  curl -sL "https://doi.org/${DOI}" \
  | gunzip | sed 's#href=#\nhref=#g' \
  | cut -d '"' -f2 \
  | egrep -i '(\.xls$|\.xlsx$|\.zip$)' \
  | sed 's#^#http://www.nature.com#' \
  | tee -a $SUPPFILELIST
done

# Uniq the url list of supp files
mv $SUPPFILELIST a
sort -u a > $SUPPFILELIST
rm a
