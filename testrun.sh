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
	./dpTDT.sh --prefix  --K --eps
#---------#---------#---------#---------#---------#---------#---------#---------
Options:
  --prefix=prefix_of_map_ped_files The file name of the .map and .ped.
  --K=number_snp    The number of most significant SNPs to output.
  --eps=privacy_budget 	The privacy budget (recommend eps <=3 and for large dataset to set eps smaller).
For the example data: 
  ./dpTDT.sh --prefix=sample --K=3 --eps=3
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
echo "Start formating: $(date)"
bash shell/formatchange.sh $PREFIX
echo "Finish formating: $(date)"
# 2. main program
echo "Start getting the output"
Rscript R/testrun.R $K $eps
echo "Done and the result is the file dpTDT_output.txt"


echo "================================================================"
echo "Desired output:"
cat testrun/desired_output.txt 

echo "================================================================"
echo "Testrun output:"
cat data/dpTDT_output.txt

echo "================================================================"
echo "Compare md5 values of desired output and testrun output:"
md5 testrun/desired_output.txt 
md5 data/dpTDT_output.txt

echo "================================================================"
echo "Content difference between desired output and testrun output:"
diff testrun/desired_output.txt data/dpTDT_output.txt

# return 0 if the test run output is equal to the desired output
#        non-zero otherwise

#FOUND=`md5sum ${TESTRUN_OUTPUT} | awk '{ print $1 }'| grep -c "${DESIRED_OUTPUT_MD5}"`
#EXITCODE=$((1 - $FOUND))
#exit $EXITCODE

