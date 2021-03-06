################################################################################
# File: dpTDT.R
# Author: Meng Wang (Stanford University)
# Email : mengw1@stanford.edu
# Date  : May 2017
#---------------------------------------------------------------------------------------------------------------------------------
# Package required: 
#                NA
# Files needed: 
#               dpTDT_fn.R 
#---------------------------------------------------------------------------------------------------------------------------------
# Function parameter description:
# function: DP.TDT.topKsnp.fn
#      Input:
#                 file.name ------"tdt_count_data.txt" the genotype counts data  generated after format change from .map and .ped                   
#                 K ------ the number of significant SNPs to release
#                 eps ------ privacy budget
#                            Default: 1 
#                 DP.method.name ------ the name of DP TDT mechanism
#                                           Options: "lap.stats", "exp.stats", "exp.shd.apprx", "exp.shd.exact", "lap.pval", "lap.pval.trunc"
#                                          Default:  c("lap.stats", "exp.stats", "exp.shd.apprx") 
#                 B ------ the repeat number to evaluate utility
#                              Default: 20 
#     Output:
#                  output ---- a matrix containing top K most signiificant SNPs under DP
#                                      and utility for the selected DP TDT method
#------------------------------------------------------------------------------------------------------------------------------------------------
# parse arguments
args = commandArgs(trailingOnly=TRUE)
K = as.numeric(args[1]);
eps = as.numeric(args[2]);
tdtCountFile = paste( args[3], "/tdt_count_data.txt", sep="" )

# load functions
source("R/dpTDT_fn.R")


# run core differentially private TDT algorithm 
DP.method.name = c("lap.stats", "exp.stats", "exp.shd.apprx") 
set.seed(2017)
result = DP.TDT.topKsnp.fn(tdtCountFile, K=K, eps=eps, DP.method.name=DP.method.name, B=20)

# write to a file
outfile = paste( args[3], "/dpTDT_output.txt", sep="" )
write.table(result, file=outfile, quote=F)
