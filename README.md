# MergeReference

## (1) Introduction

&nbsp;&nbsp;***MergeReference*** is a software package that merges multiple reference panels for HLA imputation. The merged reference panel could be used for running **CookHLA** and **SNP2HLA**.


*CookHLA* : <https://github.com/WansonChoi/CookHLA>   
*SNP2HLA* : <http://software.broadinstitute.org/mpg/snp2hla/>


***


## (2) Steps


&nbsp;&nbsp;***MergeReference*** consists of the following four steps.


![Alt text](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5637342/bin/gi-2017-15-3-108f1.jpg "Steps")


&nbsp;&nbsp;The four steps of MergeReference for merging two panels into one. SNP, single nucleotide polymorphism; HLA, human leukocyte antigen.


***


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


***

## (3) Citation


Cook, S. and Han, B. (2017) ‘MergeReference: A Tool for Merging Reference Panels for HLA Imputation’, Genomics & Informatics, 15(3) **Genomics & Informatics**, pp. 108–111.

***

## (4) License
The MergeReference Software is freely available for non-commercial academic research use. For other usage, one must contact Buhm Han (BH) at buhm.han@snu.ac.kr (patent pending). WE (Seungho Cook,BH) MAKE NO REPRESENTATIONS OR WARRANTIES WHATSOEVER, EITHER EXPRESS OR IMPLIED, WITH RESPECT TO THE CODE PROVIDED HERE UNDER. IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE WITH RESPECT TO CODE ARE EXPRESSLY DISCLAIMED. THE CODE IS FURNISHED "AS IS" AND "WITH ALL FAULTS" AND DOWNLOADING OR USING THE CODE IS UNDERTAKEN AT YOUR OWN RISK. TO THE FULLEST EXTENT ALLOWED BY APPLICABLE LAW, IN NO EVENT SHALL WE BE LIABLE, WHETHER IN CONTRACT, TORT, WARRANTY, OR UNDER ANY STATUTE OR ON ANY OTHER BASIS FOR SPECIAL, INCIDENTAL, INDIRECT, PUNITIVE, MULTIPLE OR CONSEQUENTIAL DAMAGES SUSTAINED BY YOU OR ANY OTHER PERSON OR ENTITY ON ACCOUNT OF USE OR POSSESSION OF THE CODE, WHETHER OR NOT FORESEEABLE AND WHETHER OR NOT WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, INCLUDING WITHOUT LIMITATION DAMAGES ARISING FROM OR RELATED TO LOSS OF USE, LOSS OF DATA, DOWNTIME, OR FOR LOSS OF REVENUE, PROFITS, GOODWILL, BUSINESS OR OTHER FINANCIAL LOSS.
