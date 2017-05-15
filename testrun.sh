#!/bin/bash

#-----------------------------------------------------------------------------
#  File name : testrun.sh
#  Author    : Jihoon Kim
#  Email : j5kim@ucsd.edu
#  Description : A test run script for dpTDT docker 
#                 argument 1:  s
#-----------------------------------------------------------------------------

# an output from the test run
TESTRUN_OUTPUT=/opt/dpTDT/data/dpTDT_output.txt

# testrun dpTDT with example input
cd /opt/dpTDT/data
rm -f $TESTRUN_OUTPUT
bash /opt/dpTDT/dpTDT.sh --prefix=sample --N=25 --K=3 --eps=3

# "Gold Standard" desired md5 sum value of the final output
DESIRED_OUTPUT_MD5="6492b873163746dc3159db61e68f8772"

# return 0 if the test run output is equal to the desired output
#        non-zero otherwise
FOUND=`md5sum ${TESTRUN_OUTPUT} | awk '{ print $1 }'| grep -c "${DESIRED_OUTPUT_MD5}"`
EXITCODE=$((1 - $FOUND))
exit $EXITCODE