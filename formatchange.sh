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
wc -l  ${PREFIX}.map | awk '{print $1}' > snp_count.temp
# put the count number into a file
snp_count=`cat snp_count.temp`
# get family ID list with 3 family members
awk  '{  print $1, $2, $3, $4, $6}' ${PREFIX}.ped  | awk '{print $1}'  | sort | uniq -c | awk '{if($1==3) print $2}'  > rsxxxxxxx_3men.familyid

# use plink to calculate b and c
 $PLINK_ --file ${PREFIX} --tdt   --out rsxxxxxxx --noweb --allow-no-sex
 # remove the header 
 sed 1d rsxxxxxxx.tdt > rsxxxxxxx_tdt.temp

# for loop calculate all snps
 for count in $(seq 1 $snp_count)  ; do

    # get the miner and major allele
    export ALLELE1=`awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PREFIX}.ped | sed 1d | awk '{ print $6}' | sort -r| uniq | sed -n '1p' `
    export ALLELE2=`awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PREFIX}.ped | sed 1d | awk '{ print $6}' | sort -r| uniq | sed -n '2p' `
    
    # change  allele from "A T C G" into "M m", and sort within a line (this will change "m M" to "M m")
    awk  '{  print $1, $2, $3, $4, $6,  $("'"$count"'"*2+5)"  "$("'"$count"'"*2+6)}' ${PREFIX}.ped | awk '{ print $6,$7}' | sed "s/$ALLELE1/M/g" | sed "s/$ALLELE2/m/g" | perl -ane '$,=" "; print sort @F; print "\n";' > allele.temp
    # get the famID individual ID, Paternal ID, Maternal ID, pheno
    awk  '{  print $1, $2, $3, $4, $6  }' ${PREFIX}.ped > family_info.temp
    # paste the two file together and make a uniq format
    paste family_info.temp allele.temp | awk  '{  print $1, $2, $3, $4, $5,  $6"_"$7}'  > rsxxxxxxx.temp

    # make a genotype file group by family and sort the family member as first parents then child genotype 
	  cat rsxxxxxxx_3men.familyid  | \
	  while read LINE; do 
	     export GENO=`grep $LINE rsxxxxxxx.temp | sort -k3 | awk '{print $6}' | tr '\n' '\t'`
	     echo "$GENO$LINE" | awk '{OFS="\t"; print $4,$1,$2,$3}'
	  done > rsxxxxxxx_3fam.genotype


    # make a format for pattern count file and family genotype file
	  awk '$2!="0_0" && $3!="0_0" && $4!="0_0" {OFS="\t"; print $2, $3, $4}' rsxxxxxxx_3fam.genotype | sort | uniq -c | awk  '{ print  $2"+"$3"="$4, $1}' | tr '\n' '\t'  > pattern_count.temp
	  awk  '{ print  $1, $2"+"$3"="$4}' rsxxxxxxx_3fam.genotype > rsxxxxxxx_3fam.genotype_row 

    # Get snp ID 
    export RSID=`sed -n "${count}p" ${PREFIX}.map | awk '{print $2}'  `
    # Get the b and c value from plink tdt output for each snp
    grep $RSID rsxxxxxxx_tdt.temp | awk '{print $6,$7}' > b_c.temp

	  # paste b & c value and pattern_count.temp into one row
	  paste  b_c.temp pattern_count.temp >> fam_genotype_pattern.temp

 
done

 # merge the map file and genotype pattern file
 paste ${PREFIX}.map fam_genotype_pattern.temp > tdt_count_data.txt
 # the header are Chr, SNP_id, Genetic_distance, Base-pair_position and family_genotype_pattern.

 # clear the process files
 rm *.temp
 rm rsxxxxxxx*
 

 # hand calculate to double check the b and c value from family genotype pattern and plink output.
 # grep IGR2011b_1 tdt_count_only.txt | sed "s/M/A/g" | sed "s/m/C/g"

######################################################################################################################################################



