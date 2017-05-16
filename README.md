# dpTDT

## Introduction
dpTDT is a software to implement differential private (DP) mechanisms on transmission disequilibrium test (TDT) in genome-wide association analysis (GWAS), based on the paper "Mechanisms to Protect the Privacy of Families when Using the Transmission Disequilibrium Test in Genome-Wide Association Studies". Please contact <mengw1@stanford.edu> for bugs. 


## Simple run with Docker in 3 steps
1. Prepare the PLINK format data in a local computer directory (replace sample.ped and sample.map with your own PLINK file names). Display PLINK data structure with selected rows
(with head command) and columns (with cut command).
```bash
/Users/johndoe/MyLocalDirectory/sample.ped
/Users/johndoe/MyLocalDirectory/sample.map

$ head -n 5 sample.map
1 IGR1118a_1 0 274044
1 IGR1119a_1 0 274541
1 IGR1143a_1 0 286593
1 IGR1144a_1 0 287261
1 IGR1169a_2 0 299755

$ head -n 5 sample.ped | cut -f 1-10
IBD054  430 0 0 1 0 1  3  3  1  4  1  4  2
IBD054  412 430 431 2 2 1  3  1  3  4  1  4  2
IBD054  431 0 0 2 0 3  3  3  3  1  1  2  2
IBD058  438 0 0 1 0 3  3  3  3  1  1  2  2
IBD058  470 438 444 2 2 3  3  3  3  1  1  2  2

```

2. [Install Docker](https://www.docker.com/community-edition#/download). This is one-time job. Run the hello-world docker to test if docker is working correctly.
```bash
docker run -it hello-world
```

3. Run the Docker with mounting the directory. Replace the local data directory (/Users/johndoe/MyLocalDirectory) and the PLINK data prefix (sample) with your own version.
```bash
export MY_LOCAL_DATA_DIR="/Users/johndoe/MyLocalDirectory"
export MY_PLINK_DATA_PREFIX="sample"

docker run -it -v $MY_LOCAL_DATA_DIR:/opt/dpTDT/data j5kim/dptdt:latest bash /opt/dpTDT/dpTDT.sh --prefix=$MY_PLINK_DATA_PREFIX --N=25 --K=3 --eps=3
```



## Setup
### Dependencies 
* [plink](https://www.cog-genomics.org/plink2) (version >= 1.90).
* [R](https://www.r-project.org/) (version >= 3.3.0)


### Installation (Mac OS X/Linux)
1. Download dpTDT:    
`git clone https://github.com/mwgrassgreen/dpTDT.git`

2. Add execute permissions for [dpTDT.sh](https://github.com/mwgrassgreen/dpTDT/blob/master/dpTDT.sh):     
`cd dpTDT`    
`chmod a+x dpTDT.sh`
`chmod a+x formatchange.sh`

# Usage 
	./dpTDT.sh [--plink=/usr/local/bin/plink] --prefix --N --K --eps
(The parameter in [ ] is optinal if the corresponding command is in the system path.)


# Options
  --plink=plink\_loc	Plink location (Optional if plink is in system paths.)
  
  --prefix=prefix\_of\_map\_ped\_files The file name of the .map and .ped.
  
  --N=number\_family	The number of families.
  
  --K=number\_snp    The number of most significant SNPs to output.
  
  --eps=privacy\_budget 	The privacy budget (recommend eps <=3 and for large dataset to set eps smaller).
  
# Example
  ./dpTDT.sh [--plink=/usr/local/bin/plink] --prefix=sample --N=25 --K=3 --eps=3

# Output
 The output is the selected top K most significant SNPs under DP from the methods
   (1) the Laplace mecnanism based on the test statistic (2) the exponential mechanism based on
   the test statistic and (3) the exponential mechanism based on the shortest Hamming distance scores
   where the scores are calculated from the approximation algorithm. The utility based on 20 repeats
   for each method is also listed.
   

## License
This project is licensed under the GNU General Public License v3.0 (see the [LICENSE](https://github.com/mwgrassgreen/dpTDT/blob/master/LICENSE) file for details).    



