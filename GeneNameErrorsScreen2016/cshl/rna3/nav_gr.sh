#!/bin/bash
GRURL=http://rnajournal.cshlp.org
#http://genome.cshlp.org
#http://genesdev.cshlp.org
#http://genome.cshlp.org

> gr_supp_data_list.txt

for VOL in `seq 11 21` ; do

  for ISS in `seq 1 12` ; do


    sleep 3
    echo ${GRURL}/content/${VOL}/${ISS}.toc
    wget -q -O issue.html ${GRURL}/content/${VOL}/${ISS}.toc

    for PAPER in `grep -w suppl issue.html | cut -d '"' -f4` ; do
      sleep 3
      echo $GRURL/$PAPER
      curl -s $GRURL/$PAPER \
      | egrep '(.xls"|.xlsx"|.zip")' \
      | cut -d '"' -f2 \
      | sed "s#^#${GRURL}/#" \
      | tee -a gr_supp_data_list.txt
    done

  rm issue.html
  done

done
exit


for YEAR in `seq 2005 1 2015` ; do
echo $YEAR
http://genome.cshlp.org/content/by/year/$YEAR
	for ISSUE in `curl -s http://genesdev.cshlp.org/content/by/year/${YEAR} \
	| grep 'href="/content/vol' | cut -d '"' -f2` ; do
		echo $GRURL $ISSUE
		sleep 3
		wget -q -O index.html $GRURL$ISSUE
		#curl -s $GRURL$ISSUE > issue.html

		for PAPER in `grep 'suppl/DC1' index.html | sed 's/href=/\nhref=/' \
		| grep href | cut -d '"' -f2` ; do

			for DATURL in `curl -s $GRURL$PAPER | egrep '(.xls"|.xlsx"|.zip")' | cut -d '"' -f2` ; do
				echo $GRURL$DATURL | tee -a gr_supp_data_list.txt
			done
		done
		rm index.html
done


done
