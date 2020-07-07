#!/bin/bash
GRURL=http://mbe.oxfordjournals.org/
#http://bioinformatics.oxfordjournals.org/
#http://genome.cshlp.org

echo > gr_supp_data_list.txt

for VOL in `seq 22 32` ; do

  for ISS in `seq 1 12` ; do

    sleep 3
    echo ${GRURL}/content/${VOL}/${ISS}.toc
    wget -q -O issue.html ${GRURL}/content/${VOL}/${ISS}.toc

    for PAPER in `grep -w suppl issue.html | cut -d '"' -f4` ; do
      sleep 3
      echo $GRURL/$PAPER
      curl -s $GRURL/$PAPER \
      | egrep -i '(.xls"|.xlsx"|.zip")' \
      | cut -d '"' -f2 \
      | sed "s#^#${GRURL}/#" \
      | tee -a gr_supp_data_list.txt
    done

  rm issue.html
  done

done
exit

exit
for YEAR in `seq 2005 2015` ; do
#echo $YEAR
#http://genome.cshlp.org/content/by/year/$YEAR
	for ISSUE in `curl -s http://bioinformatics.oxfordjournals.org/content/by/year/${YEAR} \
	| grep 'href="/content/vol' | cut -d '"' -f2` ; do
		echo $GRURL $ISSUE
		sleep 3
		wget -q -O index.dtl $GRURL$ISSUE
		#curl -s $GRURL$ISSUE > issue.dtl

		for PAPER in `grep 'suppl/DC1' index.dtl | sed 's/href=/\nhref=/' \
		| grep href | cut -d '"' -f2` ; do

			for DATURL in `curl -s $GRURL$PAPER | egrep '(.xls"|.xlsx"|.zip")' | cut -d '"' -f2` ; do
				echo $GRURL$DATURL | tee -a gr_supp_data_list.txt
			done
		done
		rm index.dtl
done


done
