#!/bin/bash
#Debug:off
# set -x

# GetNcbiPapers: Get a list of papers from the journal
# Screen the papers for presence of xls supplementary files
# Written by Mark Ziemann mark.ziemann@gmail.com Jan2016

# Input file: go to NCBI pubmed, perform an advanced search based on
# Journal name and date of publication
PUBMED_RES=pubmed_result.xml

# Input file: go to NCBI pubmed, perform an advanced search based on
# Journal name and date of publication
DOI_LIST=pubmed_result_doi.txt

# Output file is a list of URLS that point to supplementary XLS files
SUPPFILELIST=supp_file_urls.txt

# Empty the output file
touch a ; mv a supp_file_urls.txt

# Extract DOIs from the xml then scrape fulltext for xls files
XML_QUERY="PubmedArticleSet/PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType='doi']"
xmlstarlet sel -t -v $XML_QUERY pubmed_result.xml > $DOI_LIST

for DOI in $(cat $DOI_LIST) ; do
  sleep 2
  echo $DOI

  ARTICLE=article.html
  URL=`curl -sL "https://doi.org/${DOI}" \
  | grep citation_full_html_url \
  | cut -d '"' -f4 \
  | sed 's#.full#/suppl/DC1#'`

  echo $URL

  curl -L "$URL"  \
  | sed 's#href#\nhref#g' \
  | egrep -i '(\.xlsx"|\.xls"|\.zip")' \
  | cut -d '"' -f2 \
  | sed 's#^#http://science.sciencemag.org#' \
  | tee -a $SUPPFILELIST
done

# Uniq the url list of supp files
mv $SUPPFILELIST a
sort -u a > $SUPPFILELIST
rm a
