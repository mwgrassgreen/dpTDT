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
bash -c " echo -e '\n'deb ${CRAN_URL}/bin/linux/ubuntu  zesty/ >>  /etc/apt/sources.list "

# add key to sign CRAN pacakges
# The Ubuntu archives on CRAN are signed with the key of 
#  "Michael Rutter <marutter@gmail.com>" with key ID E084DAB9. 
#   reference  http://cran.r-project.org/bin/linux/ubuntu/
apt-key adv --keyserver keyserver.ubuntu.com  --recv-keys E084DAB9

# update
apt-get update -y

# add specfic PPA
apt-get install -y python-software-properties software-properties-common wget zip
add-apt-repository -y ppa:marutter/rdev

# update
apt-get update -y

# upgrade
apt-get upgrade -y

# install R base version
apt-get install -y r-base

# install R packages 
apt-get install -y r-base-dev

# install PLINK
mkdir -p /opt
cd /opt
wget http://pngu.mgh.harvard.edu/~purcell/plink/dist/plink-1.07-x86_64.zip
unzip plink-1.07-x86_64.zip
cd plink-1.07-x86_64
ln -s /opt/plink-1.07-x86_64/plink /usr/local/bin/plink 