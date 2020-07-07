#!/bin/bash
set -x
#no trailing /
GRURL=http://genomebiology.biomedcentral.com
>gr_supp_data_list.txt
NUM_PAGES=`curl -s "${GRURL}/articles?query=&volume=&searchType=&tab=keyword" \
| html2text | grep -m1 Next_Page | awk '{print $(NF-1)}'`

for PAGE in `seq $NUM_PAGES` ; do
  sleep 3
  URL="${GRURL}/articles?tab=keyword&searchType=journalSearch&sort=PubDate&page=${PAGE}"
  JTAG=https://static-content.springer.com/esm/art

  for ARTICLE in `curl -s $URL | grep 'class="fulltexttitle">' | cut -d '"' -f2` ; do
    sleep 3
    curl -s ${GRURL}${ARTICLE} > article.html

    YR=`grep -m1 '<meta name="dc.source"' article.html \
    | awk '{print $(NF-1)}'`

    if [ "$YR" -ge 2006 -a "$YR" -le 2015 ] ; then
      egrep -i '(\.xlsx"|\.xls"|\.zip")' article.html \
      | sed "s#${JTAG}#\n${JTAG}#" \
      | grep ^https \
      | cut -d '"' -f1 \
      | tee -a gr_supp_data_list.txt
    fi

    rm article.html
  done
done
exit 1

