# File: functions for dpTDT
# Author: Meng Wang (Stanford University)
# Email : mengw1@stanford.edu
# Date  : May 2017


############ to get test statistics
stats = function(D) {
	    b = D[1]
	    c = D[2]
	    if( b == 0 & c == 0){
					T_D = 0
				} else {
					T_D = (b - c)^2/(b+c) # the statistics at D
				}
}


########### to get shortest Hamming distance scores from approximation algorithm
dev = function(D) {	  
	  b = D[1]
	  c = D[2]
	  if( b == 0 & c == 0){
				dev_D = c(0, 0)
			} else {
				dev_D = c(2*(b-c)/(b+c) - (b-c)^2/(b+c)^2, -2*(b-c)/(b+c) - (b-c)^2/(b+c)^2) # the gradient at D
        }

}



direc_upp = rbind(c(1, 1), c(-1, -1), c(0,1), c(-1, 0), c(0, 2), c(-2, 0), c(-1, 2), c(-2, 1), c(-1, 1), c(-2, 2)) # the directions for c > b
direc_low = rbind(c(1, 1), c(-1, -1), c(1,0), c(0,-1), c(2,0), c(0,-2), c(2,-1), c(1,-2), c(1,-1), c(2, -2))


HM.score.grad = function(b_0, c_0, n, t, direc_upp, direc_low){
	
		if (b_0 > c_0){ # since the searching region is symmetric about b=c, we only consider the upper region
			dum = b_0
			b_0 = c_0
			c_0 = dum
		} 
		D0 = c(b_0, c_0)
		T_D0 = stats(D0)
		path_stats = T_D0
		path_direc = rep(NA, 2)
		
		D = D0
		T_D = T_D0
		num_step = 0
		
		if (T_D0 < t){
			 direc = direc_upp # the directions from insignificant to significant
			 
			 while (T_D < t) {
			    dev_D = dev(D)
			    D_cand = D + t(direc) # D_1 candidates along all directions
		        direc_sel = direc[(colSums(D_cand) <= rep(n, ncol(D_cand))) & (D_cand[1,] >= rep(0, ncol(D_cand))) & (D_cand[2,] >= rep(0, ncol(D_cand))),] # select the valid moving directions such that in D_cand, b + c <= n, b >= 0, c >= 0
		        
		        if (dev_D[1] == 0 & dev_D[2] == 0){
			        D_cand = D + t(direc_sel)
			        grad_direct = numeric(ncol(D_cand))
			        for(j in 1:ncol(D_cand)){
			        	   dev_D = dev(D_cand[,j])
			        	   grad_direct[j] = crossprod(dev_D, -D_cand[,j])
			        }
			        direc_D1 = direc_sel[which.min(grad_direct), ]
		        } else {
		        	 direc_D1 = direc_sel[which.max(crossprod(dev_D, t(direc_sel))),] # the moving direction for the next step is the one maximizing inner product of the gradient and valid moving directions
		        }
		        		        
		        D = D + direc_D1
		        T_D = stats(D)
		        num_step = num_step + 1
		        path_direc = rbind(path_direc, direc_D1)
		        path_stats = c(path_stats, T_D)
		        #print(direc_D1)
		        #print(T_D)
		    }
			 
		} else {
			 direc = direc_low # the directions from significant to insignificant
		
			 while (T_D >= t) {
			 	   dev_D = dev(D)
			 	   D_cand = D + t(direc) # D_1 candidates along all directions
		        direc_sel = direc[(colSums(D_cand) <= rep(n, ncol(D_cand))) & (D_cand[1,] >= rep(0, ncol(D_cand))) & (D_cand[2,] >= rep(0, ncol(D_cand))),] # select the valid moving directions such that in D_cand, b + c <= n, b >= 0, c >= 0
		        
		        direc_D1 = direc_sel[which.min(crossprod(dev_D, t(direc_sel))),] # the moving direction for the next step is the one maximizing inner product of the gradient and valid moving directions
		        #print(direc_D1)
		        D = D + direc_D1
		        T_D = stats(D)
		        num_step = num_step + 1
		        path_direc = rbind(path_direc, direc_D1)
		        path_stats = c(path_stats, T_D)
		        #print(T_D)
		    }
		}
		
		if (T_D0 < t) {
			HM.score = -num_step 
		} else{
			 HM.score = num_step- 1
	          }
		return(HM.score)
}

#### to get the SHD approximate scores
SHD_fn = function (dat, N, thres) {
	  n = 2*N
	  A = dat[unique(rownames(dat)), ]
	  score.grad_A = numeric(nrow(A))
	   for(i in 1:nrow(A)){
	   	    #print(i)
			score.grad_A[i] = HM.score.grad(A[i,1], A[i,2], n, thres, direc_upp, direc_low)
	   }
	   score.grad_A = data.frame(score.grad_A)
	   rownames(score.grad_A) = rownames(A)
       return(score.grad_A)
}



########### to get significant index set from exponential mechanism
expon.set.sig = function(K, eps, score, sen.score){
	M = length(score)
	set.sig = rep(NA, K)
    w.score.0 = exp(eps*score/(2*K*sen.score))
    ind.inf = (1:M)[(w.score.0 == "Inf")]
    
    if (length(ind.inf) > K) {
    	return("set a smaller epsilon")
    } else {
    	w.score = w.score.0
	   	for (i in 1:K){
	   		if ( length(ind.inf) > 0) {
		    	w.score = rep(0, M)
		    	w.score[ind.inf] = 1
		     } 
			 set.sig[i] = sample(1:M, size=1, prob=w.score)
			 w.score.0[set.sig[i]] = 0
			 ind.inf = (1:M)[(w.score.0 == "Inf")]
			 w.score = w.score.0
		}
		return(set.sig) # return significant index of score
    }
 }


# to generate Laplace noise
rLap = function(n, a, b){
	    # n is sample size
	    # a is location parameter
	    # b is scale parameter
	    
	    X = sample(c(-1, 1), n, replace = TRUE) * rexp(n) # double exponential r.v. with mean 0, scale =1 and its density is f(x) = 1/2 exp(-|x|)
        X = (X + a)/b
	    return(X) # f_{(X+a)/b}(x) = b/2 exp(-|bx-a|), mean a/b and scale = 1/b
}
      
      
############# to apply DP TDT methods to the genotype counts data ##############
DP.TDT.topKsnp.fn = function(file.name, K, eps=1, DP.method.name="exp.shd.apprx", B=20, shd.exact.score.file.name=NULL) {

test.name = DP.method.name %in% c("lap.stats", "exp.stats", "exp.shd.apprx", "exp.shd.exact", "lap.pval", "lap.pval.trunc")
if ( sum(!test.name)!= 0 ) {
	wrong.name = paste(DP.method.name[!test.name], collapse=", ")
	stop(paste(wrong.name, " is/are not in the method list ('lap.stats', 'exp.stats', 'exp.shd.apprx', 'exp.shd.exact', 'lap.pval', 'lap.pval.trunc')"))
}


###################################################
####    to transform the counts of genotype to (b,c) pairs   ####
###################################################

no_col <- max(count.fields(file.name, sep = ""))
dat.00 = read.delim(file.name, sep="", col.names=1:no_col, fill=TRUE, header=FALSE)
N = dat.00[nrow(dat.00), 3]
dat.0 = dat.00[-nrow(dat.00),-(1:4)]
names.dat = dat.0[-nrow(dat.00),seq(3,dim(dat.0)[2], by=2)]
count.dat = dat.0[-nrow(dat.00),seq(4,dim(dat.0)[2], by=2)]
rownames(dat.0) = dat.00[-nrow(dat.00), 2]

names.vec = c("M_m+M_m=M_M", "M_m+M_m=m_m", "M_m+M_m=M_m", "M_M+M_m=M_M","M_m+M_M=M_M", "M_m+m_m=M_m", "m_m+M_m=M_m", "M_M+M_m=M_m","M_m+M_M=M_m", "M_m+m_m=m_m", "m_m+M_m=m_m")
dat.mx = matrix(0, nrow=dim(dat.0)[1], ncol=length(names.vec))
colnames(dat.mx) = names.vec
rownames(dat.mx) = rownames(dat.0)

for (i in 1:dim(dat.0)[1]) {
	dum = rep(0, dim(names.dat)[2])
	for (k in 1:dim(names.dat)[2]){
		 dum[k] = as.vector(count.dat[i,k])        
	     names(dum)[k] = as.vector(names.dat[i,k])
	}
	dat.mx[i,] = dum[names.vec]    
}
dat.mx[is.na(dat.mx)] = 0


dat = matrix(0, nrow=dim(dat.0)[1], ncol=8)
colnames(dat) = c("b", "c", "(2,0)", "(0,2)", "(1,1)", "(1,0)", "(0,1)", "(0,0)")
rownames(dat) = rownames(dat.0)
dat[,3:5] = dat.mx[,1:3]
dat[,6] = rowSums(dat.mx[,4:7]) #rowSums(dat.mx[,4:7], na.rm=TRUE)
dat[,7] = rowSums(dat.mx[,8:11]) #rowSums(dat.mx[,8:11], na.rm=TRUE)
#dat[is.na(dat1)] = 0

dat[,1] = 2*dat[,3]+dat[,5]+dat[,6]
dat[,2] = 2*dat[,4]+dat[,5]+dat[,7]
dat[,8] = N - rowSums(dat[,-c(1,2)])


if ("exp.shd.exact" %in% DP.method.name & is.null(shd.exact.score.file.name)){
	cat("Please add shd.exact.score.file.name to implement exp.shd.exact method. The current output result is the (b,c) pairs data. Pleas takie the (b,c) pairs data as the input for SHD_score_exact_alg.java. Then rerun DP.TDT.topKsnp.fn with output from the java code as the shd.exact.score.file.")
    return(dat)
}


###################################################
####    to transform the counts of genotype to (b,c) pairs   ####
###################################################

M = nrow(dat) # number of SNPs
thres.shd = 1 - 0.05/M
thres.pval = 0.05/M
dat.stat = (dat[,1] - dat[,2])^2/(dat[,1] + dat[,2])
dat.stat[is.na(dat.stat)] = 0 # test statistics
ind.sig.dat = order(dat.stat, decreasing=TRUE)[1:K]

output.nrow = ifelse(!is.null(B), K+1, K)
output = matrix(NA, ncol=length(DP.method.name), nrow=output.nrow)
colnames(output) = DP.method.name
rownames(output) = rep(NA, output.nrow)
rownames(output)[1:K] = paste("DP.top", 1:K, ".sig.SNP", sep="")
if (!is.null(B)) rownames(output)[K+1] = paste("utility.on", B, "repeats", sep="")
output = data.frame(output)


####  Laplace mechanism based on the test statistic ####
if ("lap.stats" %in% DP.method.name ){
	lap.scale = (2*K*8*(N-1)/N)/eps
	stat.lap = dat.stat + rLap(length(dat.stat), 0, 1/lap.scale) # test statistic + laplace noise
	ind.sig.lap = order(stat.lap, decreasing=TRUE)[1:K]
	output[1:K, "lap.stats"] = rownames(dat)[ind.sig.lap]
	
	if (! is.null(B)) {
		utility.lap.stat.B = numeric(B)
		for (b in 1:B) {
			stat.lap = dat.stat + rLap(length(dat.stat), 0, 1/lap.scale) # test statistic + laplace noise
			ind.sig.lap = order(stat.lap, decreasing=TRUE)[1:K]
			utility.lap.stat.B[b] = length(intersect(ind.sig.dat, ind.sig.lap))/length(ind.sig.dat)
		}
		output[K+1, "lap.stats"] = round(mean(utility.lap.stat.B), 2)
	}
}

#### exponential mechanism based on test statistic ####
if ("exp.stats" %in% DP.method.name ){
	score = dat.stat
	sen.score = 8*(N-1)/N
	ind.sig.expon = expon.set.sig(K, eps, score, sen.score)
	output[1:K, "exp.stats"]  = rownames(dat)[ind.sig.expon]
	
	if (! is.null(B)) {
		utility.exp.stat.B = numeric(B)
		for (b in 1:B) {
			ind.sig.expon = expon.set.sig(K, eps, score, sen.score)
		    utility.exp.stat.B[b] = length(intersect(ind.sig.dat, ind.sig.expon))/length(ind.sig.dat)
		}
		output[K+1, "exp.stats"] = round(mean(utility.exp.stat.B),2)
	}
}

	
#### exponential mechanism based on the shorest hamming distance score from approximation algorithm ####
if ("exp.shd.apprx" %in% DP.method.name ){
	thres = qchisq(thres.shd, df=1)
	dat.uq.score = SHD_fn(dat[,1:2], N, thres) 
	dat.shd = matrix(0, nrow=nrow(dat), ncol=3)
	dat.shd[,1:2] = dat[,1:2]
	rownames(dat.shd) = rownames(dat)
	score.nm = rownames(dat.uq.score)[match(rownames(dat), rownames(dat.uq.score))]
	dat.shd[,3] = dat.uq.score[score.nm,1]
	score = dat.shd[,3]
	sen.score = 1
	ind.sig.expon.ham.grad = expon.set.sig(K, eps, score, sen.score)
	output[1:K, "exp.shd.apprx"]   = rownames(dat)[ind.sig.expon.ham.grad]
	
	if (! is.null(B)) {
		utility.shd.apprx.B = numeric(B)
		for (b in 1:B) {
			ind.sig.expon.ham.grad = expon.set.sig(K, eps, score, sen.score)
		    utility.shd.apprx.B[b] = length(intersect(ind.sig.dat, ind.sig.expon.ham.grad))/length(ind.sig.dat)
		}
		output[K+1, "exp.shd.apprx"]  = round(mean(utility.shd.apprx.B),2)
	}
}


#### exponential mechanism based on the shorest hamming distance score from approximation algorithm ####
#### note that first to run the code "SHD_score_exact_alg.java" to get the SHD scores from the exact algoirithm ####
if ("exp.shd.exact" %in% DP.method.name ){
	dat.exact = read.table(shd.exact.score.file.name, sep=",")
	score.exact = dat.exact[,ncol(dat.exact)] # the SHD scores from exact algorithm
	sen.score = 1
	ind.sig.expon.ham.exact = expon.set.sig(K, eps, score, sen.score)
	output[1:K, "exp.shd.exact"]   = rownames(dat)[ind.sig.expon.ham.exact]
	
	if (! is.null(B)) {
	      utility.shd.exact.B = numeric(B)
	for (b in 1:B) {
		ind.sig.expon.ham.exact = expon.set.sig(K, eps, score, sen.score)
	    utility.shd.exact.B[b] = length(intersect(ind.sig.dat, ind.sig.expon.ham.exact))/length(ind.sig.dat)
	}
	output[K+1, "exp.shd.exact"]  = round(mean(utility.shd.exact.B),2)
	}
}	  	


#### Laplace mechanisms based on p-value ####
if ("lap.pval" %in% DP.method.name ){
	dat.pval = 1 - pchisq(dat.stat, df=1) # p-values
	sen = pchisq(4, df=1)
	lap.scale = (2*K*sen)/eps
	pval.lap = dat.pval + rLap(length(dat.pval), 0, 1/lap.scale) # test statistic + laplace noise
	ind.sig.lap = order(pval.lap, decreasing=FALSE)[1:K]
	output[1:K, "lap.pval"] = rownames(dat)[ind.sig.lap]

    if (! is.null(B)) {
	utility.lap.pval.B = numeric(B)
	for (b in 1:B) {
		pval.lap = dat.pval + rLap(length(dat.pval), 0, 1/lap.scale) # test statistic + laplace noise
	    ind.sig.lap = order(pval.lap, decreasing=FALSE)[1:K]
	    utility.lap.pval.B[b] = length(intersect(ind.sig.dat, ind.sig.lap))/length(ind.sig.dat)
	}
	output[K+1, "lap.pval"]  = round(mean(utility.lap.pval.B),2)
     }
}

#### Laplace mechanisms based on truncated p-values ####
if ("lap.pval.trunc" %in% DP.method.name ){
	dat.pval = 1 - pchisq(dat.stat, df=1) # p-values
	dat.pval.trunc = pmin(dat.pval, thres.pval) # truncated p-values	
	
	thres.t = qchisq(1-thres.pval, df=1)
	sen = abs(1 - pchisq((thres.t-4)^2/thres.t, df=1) -thres.pval)
	lap.scale = (2*K*sen)/eps
	pval.lap = dat.pval.trunc + rLap(length(dat.pval.trunc), 0, 1/lap.scale) # test statistic + laplace noise
	ind.sig.lap = order(pval.lap, decreasing=FALSE)[1:K]
	output[1:K, "lap.pval.trunc"] = rownames(dat)[ind.sig.lap]
	
	if (! is.null(B)) {
		utility.lap.trunc.pval.B = numeric(B)
		for (b in 1:B) {
			pval.lap = dat.pval.trunc + rLap(length(dat.pval.trunc), 0, 1/lap.scale) # test statistic + laplace noise
		    ind.sig.lap = order(pval.lap, decreasing=FALSE)[1:K]
		    utility.lap.trunc.pval.B[b] = length(intersect(ind.sig.dat, ind.sig.lap))/length(ind.sig.dat)
		}
		output[K+1, "lap.pval.trunc"]  = round(mean(utility.lap.trunc.pval.B),2)
	}
}

return(output)
}


