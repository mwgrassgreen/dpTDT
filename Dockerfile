### set the base image to Ubuntu
FROM ubuntu:16.04

### File author / maintainer
MAINTAINER Jihoon Kim "j5kim@ucsd.edu"

### change a working directory to /opt
WORKDIR /opt

### update the repository source list and install dependent packages
RUN apt-get update  -y                                  && \
    apt-get install -y git                              && \
    git clone https://github.com/mwgrassgreen/dpTDT.git && \
    bash /opt/dpTDT/provision.sh 

### set a working directory to /opt/dpTDT
WORKDIR /opt/dpTDT