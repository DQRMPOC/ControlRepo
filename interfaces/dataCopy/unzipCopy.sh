#!/bin/bash
#
# 1) hdb in hdbDrops directory
# 2) If zipped
# unzip into hdbMerge dir
# else
# move into hdbMerge dir
# 3) move the processingConfig into the mergeTriggers dir
#
#
# takes the following options
# -h - location of the dropped hdb which is either zipped or not.
# -m - the directory where hdb goes to be merged into main database
# -w - directory to put the .csv config to trigger it to merge into the main database
# -n - the name of the hdb
#
############################################################################
############################# local utility functions ###########################
#
usage(){
    echo "usage"
    echo " $0 "
    echo " -h <LOCATION OF HDB TO BE MOVED> (can either be an archive or a directory)"
    echo " -m <DESTINATION directory where the HDB is to end up post merge>"
    echo " -w <DESTINATION directory for the trigger csv file describing the merge processes>"
    echo " -n <NAME of the HDB> "
    return 0
}
tidyUp(){
    #
    #
    #
    return 0
}
########### ########### PARAMETER VALIDATION ########### ###########
#
declare -i argcount=8 # minimum number of arguments expected
if [ $# -ne ${argcount} ]
then
        echo "$# received, ${argcount} expected"
        usage
        exit 1
fi
#
# be good citizen and clean the campsite before leaving !
#
trap tidyUp EXIT SIGTERM
##########################################################################################
#
# parse command line arguments
#
while getopts 'h:m:w:n:' flag;
do
    case "${flag}" in
    h) hdbArchive="${OPTARG}";
        echo "-h HDB ARCHIVE==${hdbArchive}"
        ;;
    m) mergeLoc="${OPTARG}";
        echo "-m MERGELOCATION=${mergeLoc}"
        ;;
    w) mergeWatchdir="${OPTARG}";
        echo "-w MERGE WATCH DIR==${mergeWatchdir}"
        ;;
    n) hdbName="${OPTARG}";
        echo "-n HDB NAME==${hdbName}"
        ;;
    esac
done
############# ############# do work here ############# #############
#
#
# use the filetype to determine if its an tar type archive ... tar will automagically manage compressed tarballs.
#
#
if [[ ${hdbArchive##*.} == 'tgz' || ${hdbArchive##*.} == 'gz' || ${hdbArchive##*.} == 'tar' ]] ; then
    mkdir -p -v ${mergeLoc}/${hdbName}
    tar -xvf ${hdbArchive} --directory ${mergeLoc}/${hdbName}
	rm ${hdbArchive}
else
    mv -v ${hdbArchive} ${mergeLoc}
fi
#
# only do this if the last command was successful
#
if [ $? ]
then
    mv -v ${mergeWatchdir}/../processingConfig/$(basename ${hdbArchive})_hdbDrop.csv ${mergeWatchdir}/${hdbName}_Trigger.csv
else
    echo ""
    echo "ERROR:previous command failed aborting"
    exit 1
fi
#
# syncronise with any background jobs
# if not required comment the 'wait'
#
wait
exit 0
