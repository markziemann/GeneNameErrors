#!/bin/bash

#Summarise data mining
#JOURNAL = Genome Research
SUPPS=gr_supp_data_list.txt
RES=scan_results.txt

CNT=`sort -u $SUPPS | wc -l`
CNTXLS=`grep -i \.xls$ $SUPPS | sort -u | wc -l`
CNTXLSX=`grep -i \.xlsx$ $SUPPS | sort -u | wc -l`
CNTZIP=`grep -i \.zip$ $SUPPS | sort -u | wc -l`

echo "
Numfiles= $CNT
NumXLS= $CNTXLS
NumXLSX= $CNTXLSX
NumZIP= $CNTZIP
"

NUMPAPERSCANNED=`grep -v ^2 $RES | sed 's/.DC[1-9]/\t/' | cut -f1 | sort -u | wc -l`
NUMGLISTSCANNED=`grep -v ^2 $RES | cut -d '/' -f1 | sort -u | wc -l`
NUMPAPERSWMXNAMES=`grep ^2 $RES | awk '!arr[$2]++ {print $2}' | awk -F"/" '{print $(NF-1)}' | sort -u | wc -l`
NUMSUPPFILESWMXNAMES=`grep ^2 $RES | awk '!arr[$2]++ {print $2}' | wc -l`
NUMMXNAMES=`grep ^2 $RES | sort | wc -l `



echo "
NumPapersScanned= $NUMPAPERSCANNED
NumGlistsScanned= $NUMGLISTSCANNED
NumPapersAffected= $NUMPAPERSWMXNAMES
NumSuppfilesAffected= $NUMSUPPFILESWMXNAMES
NumGnamesAffected= $NUMMXNAMES
"
