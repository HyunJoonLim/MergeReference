# MergeReference

## (1) Introduction

&nbsp;&nbsp;***MergeReference*** is a software package that merges multiple reference panels for HLA imputation. The merged reference panel could be used for running **CookHLA** and **SNP2HLA**.


*CookHLA* : <https://github.com/WansonChoi/CookHLA>   
*SNP2HLA* : <http://software.broadinstitute.org/mpg/snp2hla/>


***


## (2) Steps


&nbsp;&nbsp;***MergeReference*** consists of the following four steps.


![Alt text](MergeReference/figure.jpeg "Steps")


&nbsp;&nbsp;The four steps of MergeReference for merging two panels into one. SNP, single nucleotide polymorphism; HLA, human leukocyte antigen.


## (3) Usage

### **Dependency**


* plink==1.90  
* Beagle==3.0.4   
* linkage2beagle  
* beagle2linkage  


Install PLINK (<http://pngu.mgh.harvard.edu/~purcell/plink/download.shtml>)   

Install Beagle 3 (<http://faculty.washington.edu/browning/beagle/beagle.html#download>) and copy the run file (beagle.3.0.4/beagle.jar)   

Copy linkage2beagle.jar included in the beagle 3.0.4 zip file (beagle.3.0.4/utility/linkage2beagle.jar)   

Copy beagle2linkage.jar (<http://faculty.washington.edu/browning/beagle_utilities/utilities.html>)


### **RUN**

    USAGE: ./MergeReference.csh DATA1 (.bed/.bim/.fam) DATA2 (.bed/.bim/.fam) OUTPUT plink

    
