#!/bin/bash

echoerr() { printf "%s\n" "$*" >&2; }

if [ -d "$1" ] && [ -s "$1""/Sample_PBP1A_AA.faa" ] && [ -s "$1""/Sample_PBP2B_AA.faa" ] && [ -s "$1""/Sample_PBP2X_AA.faa" ]; then
  AAseqDir=$1
  data_dir=$2
  echoerr "Data folder is $AAseqDir"
else
  echoerr "usage bash ./AAtoMICwrapper.sh data_dir"
  echoerr ""
  echoerr "data_dir is a directory that must conatin 3 files with the following exact names, respectively:"
  echoerr "Sample_PBP1A_AA.faa"
  echoerr "Sample_PBP2B_AA.faa"
  echoerr "Sample_PBP2X_AA.faa"
  echoerr ""
  echoerr "See README.txt for details"
  echoerr "Program not run"
  exit 1
fi

#
faaDir=${AAseqDir}"/Sample_AAtoMIC/faa/"
rm -rf "${faaDir}"
mkdir -p "${faaDir}"
cd "${faaDir}" || exit

cp "${data_dir}"/Ref_PBP_3.faa .
cp "${AAseqDir}"/*.faa .

#module load clustal-omega/1.2
scr1="${data_dir}/Build_PBP_AA_tableR3.2.2.R"
Rscript "${scr1}" "${faaDir}"

predir=${AAseqDir}"/Sample_AAtoMIC/pre/"
rm -rf   "${predir}"
mkdir -p "${predir}"
cp ./Sample_PBP_AA_table.csv "${predir}"

#dbdir="/scicomp/groups/OID/NCIRD/DBD/RDB/Strep_Lab/External/share/PBP_AA_to_MIC/currentDB"
#dbdir="/scicomp/groups/OID/NCIRD/DBD/RDB/Strep_Lab/External/share/PBP_AA_to_MIC/newDB"
#cp $dbdir"/"*  $predir

cd "${predir}" || exit

scr1="${data_dir}/AAtable_To_MIC_MM_RF_EN_2.R"
Rscript "${scr1}" "${predir}"

cp Sample_PBPtype_MIC2_Prediction.csv "${AAseqDir}"


echoerr "MIC pridiction results are in file:"
echoerr "$AAseqDir""/Sample_PBPtype_MIC2_Prediction.csv"



