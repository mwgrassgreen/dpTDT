#!/bin/bash
# on mac

# input the data file name after PREFIX, notice that ped and map file need to be same prefix. (eg. sample.ped sample.map)
PREFIX=$1
PLINK_=$2
# make sure there is a plink application in the same direction.
# the final output of this shell script is "tdt_count_data.txt" 
# the header are Chr, SNP_id, Genetic_distance, Base-pair_position, b, c, family_genotype_pattern.
# b and c are Transmitted minor allele count and Untransmitted allele count.

######################################################################################################################################################
### programming detail
######################################################################################################################################################
### make a for loop to run all snps
# get the snp count
snp_count=$(wc -l  ${PREFIX}.map | awk '{print $1}')

# get family ID list with 3 family members
rsxxxxxxx_3men_familyid=$(awk  '{  print $1, $2, $3, $4, $6}' ${PREFIX}.ped  | awk '{print $1}'  | sort | uniq -c | awk '{if($1==3) print $2}') 

# use plink to calculate b and c
# ln -s /dev/null rsxxxxxxx.log 
 $PLINK_ --file ${PREFIX} --tdt   --out rsxxxxxxx --noweb --allow-no-sex 
 # remove the header 
 rsxxxxxxx_tdt_temp=$(sed 1d rsxxxxxxx.tdt)

# for loop calculate all snps
 for count in $(seq 1 $snp_count)  ; do

    # get the miner and major allele
    export ALLELE1=`awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PREFIX}.ped | sed 1d | awk '{ print $6}' | sort -r| uniq | sed -n '1p' `
    export ALLELE2=`awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PREFIX}.ped | sed 1d | awk '{ print $6}' | sort -r| uniq | sed -n '2p' `
    
    # change  allele from "A T C G" into "M m", and sort within a line (this will change "m M" to "M m")
    allele_temp=$(awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PREFIX}.ped | awk '{ print $6,$7}' | sed "s/$ALLELE1/M/g" | sed "s/$ALLELE2/m/g" | perl -ane '$,=" "; print sort @F; print "\n";')
    # get the famID individual ID, Paternal ID, Maternal ID, pheno
    family_info_temp=$(awk  '{  print $1, $2, $3, $4, $6  }' ${PREFIX}.ped)
    # paste the two file together and make a uniq format
    rsxxxxxxx_temp=$(paste <(echo "$family_info_temp") <(echo "$allele_temp") | awk  '{  print $1, $2, $3, $4, $5,  $6"_"$7}')

    # make a genotype file group by family and sort the family member as first parents then child genotype 
      rsxxxxxxx_3fam_genotype=$(
      echo "$rsxxxxxxx_3men_familyid"  | \
      while read LINE; do 
         export GENO=`echo "$rsxxxxxxx_temp" | grep $LINE  | sort -k3 | awk '{print $6}' | tr '\n' '\t'`
         echo "$GENO$LINE" | awk '{OFS="\t"; print $4,$1,$2,$3}'
      done
      )


    # make a format for pattern count file and family genotype file
      pattern_count_temp=$(echo "$rsxxxxxxx_3fam_genotype" | awk '$2!="0_0" && $3!="0_0" && $4!="0_0" {OFS="\t"; print $2, $3, $4}' | sort | uniq -c | awk  '{ print  $2"+"$3"="$4, $1}' | tr '\n' '\t')
      rsxxxxxxx_3fam_genotype_row=$(echo "$rsxxxxxxx_3fam_genotype" | awk  '{ print  $1, $2"+"$3"="$4}')

    # Get snp ID 
    export RSID=`sed -n "${count}p" ${PREFIX}.map | awk '{print $2}'  `
    # Get the b and c value from plink tdt output for each snp
    b_c_temp=$(echo "$rsxxxxxxx_tdt_temp" | grep $RSID | awk '{print $6,$7}')


      # paste b & c value and pattern_count.temp into one row
      paste <(echo "$b_c_temp") <(echo "$pattern_count_temp") >> fam_genotype_pattern.temp

 
done

 # merge the map file and genotype pattern file
 paste ${PREFIX}.map fam_genotype_pattern.temp > tdt_count_data.txt
 #paste <(cat ${PREFIX}.map) <(echo "$am_genotype_pattern_temp")> tdt_count_data.txt
 # the header are Chr, SNP_id, Genetic_distance, Base-pair_position and family_genotype_pattern.

 # clear the process files
 rm *.temp
 rm rsxxxxxxx*
 

 # hand calculate to double check the b and c value from family genotype pattern and plink output.
 # grep IGR2011b_1 tdt_count_only.txt | sed "s/M/A/g" | sed "s/m/C/g"

######################################################################################################################################################



