#!/bin/bash
#---------#---------#---------#---------#---------#---------#---------#---------
usage="
#---------#---------#---------#---------#---------#---------#---------#---------
# Introduction: 
        dpTDT is a sofware to implement differential private (DP) mechanism on 
    transmission disequilibrium test (TDT) in genome-wide association analysis (GWAS),
	based on the paper---Mechanisms to Protect the Privacy of Families when Using 
	the TDT in GWAS. It requires plink (https://www.cog-genomics.org/plink2 v1.90 or later.
    Please contact mengw1@stanford.edu for bugs.
#---------#---------#---------#---------#---------#---------#---------#---------
Usage: 
	./dpTDT.sh [--plink=/usr/local/bin/plink] --prefix --N --K --eps
# (The parameters in [ ] are optinal if the corresponding command is in system path.)
#---------#---------#---------#---------#---------#---------#---------#---------
Options:
  --plink=plink_loc	Plink location (Optional if plink is in system paths.)
  --prefix=prefix_of_map_ped_files The file name of the .map and .ped.
  --N=number_family	The number of families.
  --K=number_snp    The number of most significant SNPs to output.
  --eps=privacy_budget 	The privacy budget (recommend eps <=3 and for large dataset to set eps smaller).
For the example data: 
  ./dpTDT.sh [--plink=/usr/local/bin/plink] --prefix=sample --N=25 --K=3 --eps=eps
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
PLINK_=plink;
# For R script
N=;
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
		--plink=*)
			PLINK_=`echo "${1}" | ${SED_} -e 's/[^=]*=//'`;;
		--N=*)
			N=`echo "${1}" | ${SED_} -e 's/[^=]*=//'`;;
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
echo "Start formating: $(date)"
../formatchange.sh $PREFIX $PLINK_
echo "Finish formating: $(date)"
# 2. main program
echo "Start getting the output"
Rscript ../R/dpTDT.R $N $K $eps
echo "Done and the result is the file dpTDT_output.txt"


 
