#!/bin/bash
#
# sync for sandbox(s) although could be for almost files
# 
# typical command line will look something like
#     /data02/trva8.4.0.0P4.linux.drop.FT_angus/packages/DaaSPlatform_3_0_0P4/interfaces/datacopy/./zipCopy.sh \
#          -z /data02/trva8.4.0.0P4.linux.drop.FT_angus/delta-data/DaaSData/tmp/dataCopyZipDir/EMEA_TR_2018.11.18.tgz \
#          -h /data02/trva8.4.0.0P4.linux.drop.FT_angus/delta-data/DaaSData/hdblog/EMEA/TR/EQ \
#          -d '2018.11.18 sym' \
#          -t '64.209.200.39:/data02/trva8.4.0.0P4.linux.drop.FT_angus/delta-data/fileStore/hdbDrops/EMEA_TR_2018.11.18.tgz' \
#          -p '64.209.200.39:/data02/trva8.4.0.0P4.linux.drop.FT_angus/delta-data/fileStore/processingConfig/EMEA_TR_2018.11.18.tgz_hdbDrop.csv' 2>&1 &
#
###################################################################################
usage(){
        echo ""
    echo "usage: (all ARGS are MANDATORY !)"
        echo "$0 "
    echo " -z <zipfile to create>"
    echo " -h <hdb directory path of data being copied>"
    echo " -d '<dates to be copied> ... , there can be multiple dates, separated by a space, the 'sym' file is automatically added"
    echo " -t '<host:[directory]> ... destination of the zipfile, there can be multiple destinations separated by spaces " 
    echo " -p '<host:[directory]> ... destination of config csv details of the hdb copy, there can be multiple destinations separated by spaces " 
    echo ""
    return 0
}
tidyUp(){
    #
    # 
    #
    echo "tidying up....${zipFil} being removed"
    
    rm -f ${zipFile}
}
    
declare -i argcount=10 # expect this many arguments on the command line
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
# parse arguments
#
while getopts 'z:h:d:t:p:' flag; do
  case "${flag}" in
    d) datesToCopy="${OPTARG}" ;;
    h) hdbDir="${OPTARG}" ;;
    t) targets="${OPTARG}" ;;
    z) zipFile="${OPTARG}" ;;
    p) processFlagLoc="${OPTARG}" ;;
    ?) usage;;
  esac
done
##########################################################################################
#
# create zip archive of requested dates.
# We add the 'sym' file to ensure enumerations are in sync.
# if the user has specified the sym file on the command line it will not duplicate
#
# the -C${hdbDir} on the tar line doesn't help if wildcards are used ie 2018.10.*
# so we cd to $hdbDir directly and cd back to where we came from once done
# 
cdir=$(pwd)
cd ${hdbDir}
echo "tar -zcvf ${zipFile} -C${hdbDir} ${datesToCopy} sym"
tar -zcvf ${zipFile} -C${hdbDir} ${datesToCopy} sym
if [ $? -ne 0 ]
then
    echo "tar command failed, aborting"
    exit 1
fi
cd ${cdir}
#
# (rsync doesnt work immediately for some reason???)
# 
rsync --version --help > /dev/null
#
# spawn background job to push zip archive to each target
#
for target in $targets
do
    echo "rsync --verbose ${zipFile} ${target} &"
    rsync --verbose ${zipFile} ${target} &
done
#
# spawn background job to push processing configs to each target
#
for pcfg in ${processFlagLoc}
do
    touch ${zipFile}_hdbDrop.csv
    echo "rsync --verbose ${zipFile}_hdbDrop.csv ${pcfg} &"
    rsync --verbose ${zipFile}_hdbDrop.csv ${pcfg} &
done
#
# syncronise jobs to complete
#
wait
exit 0