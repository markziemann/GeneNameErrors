#!/bin/bash

#Summarise data mining
#JOURNAL = Genome Research
SUPPS='supp_file_urls_GSMonly.txt batch1_GSE/supp_file_urls_GSEonly.txt'
RES='scan_results.txt batch1_GSE/scan_results.txt'

CNT=`cat $SUPPS | wc -l`
CNTXLS=`grep -i \.xls$ $SUPPS | sort -u | wc -l`
CNTXLSX=`grep -i \.xlsx$ $SUPPS | sort -u | wc -l`
CNTZIP=`grep -i \.zip$ $SUPPS | sort -u | wc -l`

echo "
Numfiles= $CNT
NumXLS= $CNTXLS
NumXLSX= $CNTXLSX
NumZIP= $CNTZIP
"

NUMGLISTSCANNED=`grep -i species $RES | cut -d ' ' -f1 | rev | cut -d '.' -f2- | rev | sort -u | wc -l`
NUMPAPERSWMXNAMES=`grep ^2 $RES | awk '!arr[$2]++ {print $2}' | rev | cut -d '/' -f2- | sort -u | wc -l`
NUMSUPPFILESWMXNAMES=`grep ^2 $RES | awk '!arr[$2]++ {print $2}' | wc -l`
NUMMXNAMES=`grep ^2 $RES | sort | wc -l `



echo "
NumGlistsScanned= $NUMGLISTSCANNED
echo Here papers means GEO accessions
NumPapersAffected= $NUMPAPERSWMXNAMES
NumSuppfilesAffected= $NUMSUPPFILESWMXNAMES
NumGnamesAffected= $NUMMXNAMES
"
