#!/bin/bash

# input the data file name after PREFIX, notice that ped and map file need to be same prefix. (eg. sample.ped sample.map)
PLINK_PREFIX_FULLPATH=$1

WORKDIR=$(dirname $PLINK_PREFIX_FULLPATH)
PREFIX=$(basename $PLINK_PREFIX_FULLPATH)

TEMPFILE_3MEMBER=${WORKDIR}/3mem_family_list.tmp
TEMPFILE_GENOPATTERN=${WORKDIR}/fam_genotype_pattern.tmp
OUTPUT_FILE=${WORKDIR}/tdt_count_data.txt


# the final output of this shell script is "tdt_count_data.txt" 
# the header are Chr, SNP_id, Genetic_distance, Base-pair_position, family_genotype_pattern.

######################################################################################################################################################
### programming detail
######################################################################################################################################################

#cd ./workspace/

# get the snp count
snp_count=$(wc -l  ${PLINK_PREFIX_FULLPATH}.map | awk '{print $1}')

# get family ID list with 3 family members
rsxxxxxxx_3men_familyid=$(awk  '{  print $1, $2, $3, $4, $6}' ${PLINK_PREFIX_FULLPATH}.ped  | awk '{print $1}'  | sort | uniq -c | awk '{if($1==3) print $2}') 
 echo "$rsxxxxxxx_3men_familyid"  | \
 while read LINE; do 
     one_family_ped_info=$(awk  '{  print $1, $2, $3, $4, $5, $6}' ${PLINK_PREFIX_FULLPATH}.ped   | grep -w $LINE)
     paternal_ID=$(echo "$one_family_ped_info" | awk '$6 ==2 && $3!=0 {print $3 }')
     maternal_ID=$(echo "$one_family_ped_info" | awk '$6 ==2 && $4!=0 {print $4 }')
     count_paternal_ID=$(echo "$one_family_ped_info" | grep $paternal_ID | wc -l )
     count_maternal_ID=$(echo "$one_family_ped_info" | grep $maternal_ID | wc -l )
     if [ "$count_paternal_ID" -eq 2 ] && [ "$count_maternal_ID" -eq 2 ]
      then 
      echo $LINE >> ${TEMPFILE_3MEMBER}
     fi 

 done
# get family number count
N=$(cat ${TEMPFILE_3MEMBER} | wc -l | awk '$1=$1')

# for loop calculate all snps
for count in $(seq 1 $snp_count)  ; do

    # get the miner and major allele
    export ALLELE1=`awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PLINK_PREFIX_FULLPATH}.ped | sed 1d | awk '{ print $6}' | sort -r| uniq | sed -n '1p' `
    export ALLELE2=`awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PLINK_PREFIX_FULLPATH}.ped | sed 1d | awk '{ print $6}' | sort -r| uniq | sed -n '2p' `
    
    # change  allele from "A T C G" into "M m", and sort within a line 
    allele_temp=$(awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PLINK_PREFIX_FULLPATH}.ped | awk '{ print $6,$7}' | sed "s/$ALLELE1/M/g" | sed "s/$ALLELE2/m/g" | perl -ane '$,=" "; print sort @F; print "\n";')
    # get the famID individual ID, Paternal ID, Maternal ID, pheno
    family_info_temp=$(awk  '{  print $1, $2, $3, $4, $6  }' ${PLINK_PREFIX_FULLPATH}.ped)
    # paste the two file together and make a uniq format
    rsxxxxxxx_temp=$(paste <(echo "$family_info_temp") <(echo "$allele_temp") | awk  '{  print $1, $2, $3, $4, $5,  $6"_"$7}')

    # make a genotype file group by family and sort the family member 
      rsxxxxxxx_3fam_genotype=$(
      echo "$rsxxxxxxx_3men_familyid"  | \
    while read LINE; do 
         export GENO=`echo "$rsxxxxxxx_temp" | grep $LINE  | sort -k3 | awk '{print $6}' | tr '\n' '\t'`
       echo "$GENO$LINE" | awk '{OFS="\t"; print $4,$1,$2,$3}'
    done
      )

    # make a format for pattern count file and family genotype file
    pattern_count_temp=$(echo "$rsxxxxxxx_3fam_genotype" | awk '$2!="0_0" && $3!="0_0" && $4!="0_0" {OFS="\t"; print $2, $3, $4}' | sort | uniq -c | awk  '{ print  $2"+"$3"="$4, $1}' | tr '\n' '\t')
      echo "$pattern_count_temp" >> ${TEMPFILE_GENOPATTERN}
done

 # merge the map file and genotype pattern file
 paste ${PLINK_PREFIX_FULLPATH}.map ${TEMPFILE_GENOPATTERN} > ${OUTPUT_FILE}
 echo "N = $N " >> ${OUTPUT_FILE}
 # the header are Chr, SNP_id, Genetic_distance, Base-pair_position and family_genotype_pattern.

 #  remove the temporary files
rm -f ${TEMPFILE_3MEMBER}
rm -f ${TEMPFILE_GENOPATTERN}

######################################################################################################################################################
