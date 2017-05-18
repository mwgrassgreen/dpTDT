#!/bin/bash

#-----------------------------------------------------------------------------
# Author : Jihoon Kim 
# Email : j5kim@ucsd.edu
# Description: A provisioning script to install R and PLINK for 
#              differentially private Transmission Disequilibrium Test (dpTDT)
#              docker
#-----------------------------------------------------------------------------
# add CRAN (https://cran.r-project.org/) to sources.list
export CRAN_URL=http://cran.stat.ucla.edu
bash -c " echo -e '\n'deb ${CRAN_URL}/bin/linux/ubuntu xenial/ >>  /etc/apt/sources.list "

# update
apt-get update -y

# install dependant packages
apt-get install -y apt-utils python-software-properties software-properties-common wget zip

# add key to sign CRAN pacakges
# The Ubuntu archives on CRAN are signed with the key of 
#  "Michael Rutter <marutter@gmail.com>" with key ID E084DAB9. 
#   reference  http://cran.r-project.org/bin/linux/ubuntu/
apt-key adv --keyserver keyserver.ubuntu.com  --recv-keys E084DAB9

# add specfic PPA
add-apt-repository -y ppa:marutter/rdev

# update
apt-get update -y

# upgrade
apt-get upgrade -y

# install R base version
apt-get install -y r-base

# create directoris
mkdir -p /opt/dpTDT
mkdir -p /opt/dpTDT/data