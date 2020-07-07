#!/bin/bash
#wipe the urls file
>supp_file_urls.txt

#Go to ths URL to find relevent geo series --> 5580 were identified on 2016-04-26
#http://www.ncbi.nlm.nih.gov/gds?term=(((%22xls%22%5BSupplementary%20Files%5D%20OR%20%22xlsx%22%5BSupplementary%20Files%5D)))%20AND%20(%222005%22%5BPublication%20Date%5D%20%3A%20%222015%22%5BPublication%20Date%5D)

#search each series that has deposited xls files
for GSEURL in `grep '(XLS' gds_result.txt \
| tr ' ' '\n' \
| egrep '(GSM)' \
| tr -d ',' \
| sed 's@$@suppl/@'` ; do

  sleep $(((RANDOM/10000)+10))

  echo "$GSEURL"

  wget -q -O- "$GSEURL" \
  | grep -i '.xls' \
  | cut -d '"' -f2 \
  | tee -a supp_file_urls.txt

done
rm index.html
