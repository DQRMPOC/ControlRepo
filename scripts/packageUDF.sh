#!/bin/bash


[ $# -eq 0 ] && { echo "Script to package user defined functions into an installable package";echo "Usage: $0 install_directory"; exit 1; }



#check provided directory is correct
if [ ! -d $1/delta-data ]; then
        echo "Specified path is not valid install directory"
        exit 1;
fi


#put instal config in udfdir

name="UDF_0_0_0_$(date +%Y%m%d)"

mkdir -p $1/delta-data/DaaSData/udfdir/${name}/install_config/profiles
echo 'CPY|UDFs|dir|${DELTA_HOME}/delta-data/DaaSData/udfdir|' >> $1/delta-data/DaaSData/udfdir/${name}/install_config/profiles/UDF.install.config

mkdir -p $1/delta-data/DaaSData/udfdir/${name}/UDFs
cp -r $1/delta-data/DaaSData/udfdir/*  $1/delta-data/DaaSData/udfdir/${name}/UDFs 2>>/dev/null
rm -rf $1/delta-data/DaaSData/udfdir/${name}/UDFs/archived
rm -rf $1/delta-data/DaaSData/udfdir/${name}/UDFs/${name}


#tar up dir
tar -C $1/delta-data/DaaSData/udfdir -zcf ${name}.tgz $name
rm -rf $1/delta-data/DaaSData/udfdir/${name}

