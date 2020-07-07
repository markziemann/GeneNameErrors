#!/bin/bash
set -x
GRURL=https://bmcbioinformatics.biomedcentral.com
>gr_supp_data_list.txt
NUM_PAGES=`curl -s "${GRURL}/articles?query=&volume=&searchType=&tab=keyword" \
| html2text | grep -m1 Next_Page | awk '{print $(NF-1)}'`

for PAGE in `seq $NUM_PAGES` ; do
  sleep 3
  URL="https://bmcbioinformatics.biomedcentral.com/articles?tab=keyword&searchType=journalSearch&sort=PubDate&page=${PAGE}"
  JTAG=https://static-content.springer.com/esm/art

  for ARTICLE in `curl -s $URL | grep 'class="fulltexttitle">' | cut -d '"' -f2` ; do
    sleep 3
    curl -s ${GRURL}${ARTICLE} > article.html

    YR=`grep -m1 '<meta name="dc.source"' article.html \
    | awk '{print $(NF-1)}'`

    if [ "$YR" -ge 2005 -a "$YR" -le 2015 ] ; then
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
for ARTICLE in `curl -s http://www.biomedcentral.com/bmcbioinformatics/content/${VOL}/${MONTH}/${YEAR} \
| grep 'Abstract' | cut -d '"' -f2` ; do
  echo $GRURL $ISSUE
  sleep 3
  echo $ARTICLE
  curl -s $ARTICLE | grep Additional | grep supplementary | sed 's/href="/\n/g' \
  | cut -d '"' -f1 | egrep -i '(\.xls$|\.xls$|\.zip$)' | tee -a gr_supp_data_list.txt
done

