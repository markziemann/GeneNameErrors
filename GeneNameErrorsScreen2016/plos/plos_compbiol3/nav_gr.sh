#!/bin/bash
set -x
GRURL=http://journals.plos.org/ploscompbiol
>gr_supp_data_list.txt

for VOL in `seq -w 1 11` ; do

  for ISS in `seq -w 1 12` ; do

    TOC=http://journals.plos.org/ploscompbiol/issue?id=info%3Adoi%2F10.1371%2Fissue.pcbi.v${VOL}.i${ISS}

    for ARTICLENUM in `curl -sL "$TOC" | grep journal.pcbi | grep ploscompbiol | cut -d '"' -f2 | awk -F\. '{print $NF}'` ; do

      ARTICLE=http://journals.plos.org/ploscompbiol/article?id=10.1371%2Fjournal.pcbi.$ARTICLENUM
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
