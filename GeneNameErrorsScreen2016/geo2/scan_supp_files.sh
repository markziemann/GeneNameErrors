#!/bin/bash

################################################################################
#
# scan_supp_files.sh simply downloads files (like supplementary data) and
# screens the contents for gene name errors introduced by MS excel or similar.
#
# by Mark Ziemann email:mark.ziemann@gmail.com
#
################################################################################

set -x
#supp file list is a list of URLS that point to xls, xlsx or zip files.
SUPPFILELIST=supp_file_urls_GSMonly.txt

#Gene lists are necessary to determine whether input data are also gene lists
#Gene lists specified here MUST have the _genes suffix
#/home/mziemann/bioinformatics/supp_scan/supp_scan/geo2/batch1
GENELIST_DIR='../genelists/'

#Set number of parallel jobs
PARALLEL_JOBS=4

## scanit is function used which downloads each file and screens it for gene
## lists and Excel gene name errors. This function is called in parallel to
## speed things up
scanit(){
set -x
sleep 3
DATE=`date +%Y-%m-%d`	#Record the date for record-keeping purposes
DOI=`echo $1 | cut -d '@' -f1`		#Extract DOI from input line
SUPP_URL=`echo $1 | cut -d '@' -f2`	#Extract Supp URL from input line
echo $SUPP_URL
RES=scan_results.txt	#Write the results to this file
SUPPFILELIST=gr_supp_data_list.txt
#supp_file_urls.txt		#Might not need this

## Gene lists are necessary to determine whether data are gene lists
GENELIST_DIR="$2"
GENELISTS="${GENELIST_DIR}*_genes"

#Create names for working directory and working files.
TEMP_DIR=`echo $SUPP_URL | tr '/:%' '_'`
mkdir $TEMP_DIR

FILE_SFX=`echo $SUPP_URL | rev | cut -d '.' -f1 | rev `
TEMP_FILE=$TEMP_DIR/download.$FILE_SFX

#Check the filename in case its a ZIP archive
ZIP=`echo $SUPP_URL | grep -wci zip$`
if [ "$ZIP" -eq "1" ] ; then

  #Download the file with wget
  wget -O $TEMP_FILE $SUPP_URL

  #check the contents of the zip file for xls/xlsx files
  XLSCNT=`unzip -l $TEMP_FILE | egrep -wci '(.xls$|.xlsx$)'`
  if [ "$XLSCNT" -gt "0" ] ; then
    unzip $TEMP_FILE -d $TEMP_DIR
    for NEWDAT in `find $TEMP_DIR | egrep -i '(.xls$|.xlsx$)' ` ; do
      #Extract xls files into tab separated text files with ssconvert
      ssconvert -S --export-type Gnumeric_stf:stf_assistant -O 'separator="'$'\t''"' \
      $NEWDAT $NEWDAT.txt 2> /dev/null

      #count the columns in each sheet
      for SHEET in $NEWDAT.txt* ; do
        TMP=$SHEET.tmp
	head $SHEET
        NF=`head $SHEET | awk '{print NF}' | numaverage -M`

        #intersect top 20 fields from each column of data with gene name lists
        for COL in `seq $NF` ; do
          cut -f$COL $SHEET | head -20 > $TMP

          #Guess which species based on top 20 cells of the field
          SPEC=`grep -cxFf $TMP $GENELISTS | awk -F: '$2>4' | sort -t\: -k2gr \
          | head -1 | cut -d ':' -f1 | tr '/' ' ' | awk '{print $NF}' \
          | cut -d '_' -f1`

          #If >4 of the top 20 cells are recognised as genes, then regex with awk
          if [ -n "$SPEC" ] ; then
            echo $DOI $SUPP_URL $COL $SPEC | tee -a $RES
            #Run the regen screen on the column
            cut -f$COL $SHEET | sed '1,2d' \
	    | awk ' /[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]/ || /[0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ || (/[0-9]\-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/) || /[0-9]\.[0-9][0-9]E\+[0-9][0-9]/ ' \
            | sed "s#^#${DATE}\t${DOI}\t${SUPP_URL}\t${COL}\t#" | tee -a $RES
          fi
        done
      done
    done
  fi
#Delete the working directory
rm -rf $TEMP_DIR
exit
fi


#if the file isn't a zip archive, just download it
curl -s $SUPP_URL > $TEMP_FILE

GZ=`echo $TEMP_FILE | grep -c .gz$`
if [ $GZ -eq "1" ] ; then
  gunzip $TEMP_FILE
  TEMP_FILE=`echo $TEMP_FILE | sed 's#.gz$##'`
fi

#Extract xls files into tab separated text files
ssconvert -S --export-type Gnumeric_stf:stf_assistant -O 'separator="'$'\t''" ' \
$TEMP_FILE $TEMP_FILE.txt 2> /dev/null

#count the columns in each sheet
for SHEET in $TEMP_FILE.txt* ; do
  TMP=$SHEET.tmp
  NF=`head $SHEET | awk '{print NF}' | numaverage -M`

  #intersect top 20 fields from each column of data with a list of gene names
  for COL in `seq $NF` ; do
    cut -f$COL $SHEET | head -20 > $TMP

    #Guess which species - this is not 100% correct as search as only 20
    #fields are scanned
    SPEC=`grep -cxFf $TMP $GENELISTS | awk -F: '$2>4' | sort -t\: -k2gr \
    | head -1 | cut -d ':' -f1 | tr '/' ' ' | awk '{print $NF}' \
    | cut -d '_' -f1`

    #If >4 of the top 20 cells are recognised as genes, then regex with awk
    if [ -n "$SPEC" ] ; then
      echo $SHEET col:$COL species:$SPEC | tee -a $RES
      #Run the regen screen on the column
      cut -f$COL $SHEET | sed '1,2d' \
      | awk ' /[0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]/ || /[0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ || (/[0-9]\-(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/) || /[0-9]\.[0-9][0-9]E\+[0-9][0-9]/ ' \
      | sed "s#^#${DATE}\t${DOI}\t${SUPP_URL}\t${COL}\t#" | tee -a $RES
    fi
  done
done
#delete the working directory
rm -rf $TEMP_DIR
}

export -f scanit

#Ensure that the results file is empty
touch a ; mv a scan_results.txt

#Now run the function in parallel
sort -u $SUPPFILELIST | tr '\t' '@' \
| parallel --delay 11 -j3 scanit "{}" "$GENELIST_DIR" 2> scan_sterr.txt

#| parallel -j$PARALLEL_JOBS scanit "{}" "$GENELIST_DIR"

