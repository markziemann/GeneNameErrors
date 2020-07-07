#!/bin/bash
set -x
GRURL=http://www.nature.com/ng/archive/index.html
echo > gr_supp_data_list.txt
for VOL in `seq 37 1 47` ; do
#for VOL in 37 ; do
  sleep 3

  for ISS in `seq 1 1 12` ; do
#  for ISS in 1 ; do
    sleep 3
    echo $VOL $ISS http://www.nature.com/ng/journal/v${VOL}/n${ISS}/index.html

    for SUPPS in `curl -s http://www.nature.com/ng/journal/v${VOL}/n${ISS}/index.html \
    | grep -i '">Supplementary Information</a>' | sed 's/href=/\nhref=/g' \
    | cut -d '"' -f2 | grep html$` ; do
      echo $SUPPS
      sleep 3

#      ID=`echo $SUPPS | sed 's#/abs/#/suppinfo/#' | sed 's#.html#_S1.html#' | sed 's#S1_S1.html#S1.html#'`
#      echo http://www.nature.com$ID

#      curl -s http://www.nature.com$ID | sed 's/"/\n/g' \
#      | egrep -i '(\.xls$|\.xlsx$|\.zip$)' | sed 's#^#http://www.nature.com#' \
#      | tee -a gr_supp_data_list.txt

      curl -s http://www.nature.com$SUPPS \
      | sed 's#href=#\nhref=#g' \
      | cut -d '"' -f2 \
      | egrep -i '(\.xls$|\.xlsx$|\.zip$)' \
      | sed 's#^#http://www.nature.com#' \
      | tee -a gr_supp_data_list.txt

    done
  done
done
