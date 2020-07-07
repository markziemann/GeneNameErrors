#!/bin/bash
set -x
GRURL=http://www.plosbiology.org
>gr_supp_data_list.txt

for VOL in `seq -w 3 13` ; do

  for ISS in `seq -w 1 12` ; do

    TOC=http://www.plosbiology.org/article/browse/issue/info%3Adoi%2F10.1371%2Fissue.pbio.v${VOL}.i${ISS}

    for ARTICLENUM in `curl -sL "$TOC" | grep journal.pbio | grep Adoi | cut -d '"' -f2 | awk -F\. '{print $NF}'` ; do
      ARTICLE=http://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.$ARTICLENUM
      sleep 3
      echo $ARTICLE

      curl -L "$ARTICLE" \
      | egrep -i '(xlsx\)|xls\)|zip\))' \
      | sed 's#href#\nhref#g' \
      | grep href \
      | awk -F \" '{print $2}' \
      | awk -F \/ '{print $NF}' \
      | sed 's#^#http://dx.plos.org/10.1371/#' \
      | tee -a gr_supp_data_list.txt

    done
  done
done
