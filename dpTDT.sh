################################################################################
# File: dpTDT.sh
# Author: Meng Wang (Stanford University)
# Email : mengw1@stanford.edu
# Date  : May 2017
#---------------------------------------------------------------------------------------------------------------------------------
#!/bin/bash
#---------#---------#---------#---------#---------#---------#---------#---------
usage="
#---------#---------#---------#---------#---------#---------#---------#---------
# Introduction: 
        dpTDT is a sofware to implement differential private (DP) mechanism on 
    transmission disequilibrium test (TDT) in genome-wide association analysis (GWAS),
	based on the paper---Mechanisms to Protect the Privacy of Families when Using 
	the TDT in GWAS. It requires R (https://www.r-project.org/) v3.3.0 or later.
    Please contact mengw1@stanford.edu for bugs.
#---------#---------#---------#---------#---------#---------#---------#---------
Usage: 
	./dpTDT.sh --prefix  --K --eps
#---------#---------#---------#---------#---------#---------#---------#---------
Options:
  --prefix=path/prefix_of_map_ped_files The path of the .map and .ped files added the file prefix 
  where the .map and .ped files are the input data in PLINK format.
  --K=number_snp    The number of most significant SNPs to output.
  --eps=privacy_budget 	The privacy budget (recommend eps <=3 and for large dataset to set eps smaller).
For the example data: 
  ./dpTDT.sh --prefix=./example/sample --K=3 --eps=3
#---------#---------#---------#---------#---------#---------#---------#---------
Output:
         The output is the selected top K most significant SNPs under DP from the methods--
   (1) the Laplace mecnanism based on the test statistic (2) the exponential mechanism based on
   the test statistic and (3) the exponential mechanism based on the shortest Hamming distance scores
   where the scores are calculated from the approximation algorithm. The utility based on 20 repeats
   for each method is also listed.
#---------#---------#---------#---------#---------#---------#---------#---------   	 
"
# 0. parameter setting
# For format chage
PREFIX=;
# For R script
K=;
eps=;
#---------#---------#---------#---------#---------#---------#---------#---------
# Arguments loop
SED_=sed;
[ -x "$(command -v $SED_)" ] || { echo "SED is not working ($SED_)" && exit 1; }
while test -n "${1}"; do
	case ${1} in
		--prefix=*)
			PREFIX=`echo "${1}" | ${SED_} -e 's/[^=]*=//'`;;
		--K=*)
			K=`echo "${1}" | ${SED_} -e 's/[^=]*=//'`;;
		--eps=*)
			eps=`echo "${1}" | ${SED_} -e 's/[^=]*=//'`;;
		*)
			echo $"${1} is not available for $0!";
			exit 1;;	
	esac
	shift;
done
#---------#---------#---------#---------#---------#---------#---------#---------
# 1. formart change
echo "Start formatting: $(date)."
bash shell/formatchange.sh $PREFIX
WORKDIR=$(dirname $PREFIX)
PREFIX=$(basename $PREFIX)
echo "Finish formatting: $(date)."


# 2. main program
echo "Start getting the output."
Rscript R/dpTDT.R $K $eps $WORKDIR
echo "Done and the result is the file dpTDT_output.txt under the folder example."


 
