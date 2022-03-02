#!/bin/csh -f

######################################################################################################
#
# MergeReference.csh
#
# Author: Cook Seungho(kukshomr@gmail.com)
# DESCRIPTION: 
# 
# INPUTS: 
# 1. Plink dataset
# 2. Plink dataset
# 
# DEPENDENCIES: (download and place in the same folder as this script)
# 1. PLINK (1.07)
# 2. Beagle (3.0.4)
# 3. merge_tables.pl (Perl script to merge files indexed by a specific column)
# 4. linkage2beagle and beagle2linkage (Beagle utilities for PED <-> Beagle format)
#
# 
#
######################################################################################################

if ($#argv < 4) then
    echo "USAGE: ./MergeReference.csh DATA1 (.bed/.bim/.fam) DATA2 (.bed/.bim/.fam) OUTPUT plink" ; exit 1
endif

set SCRIPTPATH=`dirname $0`

set MERGE=$SCRIPTPATH/merge_tables.pl



# CHECK FOR DEPENDENCIES
if (! -e `which $4`) then
    echo "Please install PLINK (http://pngu.mgh.harvard.edu/~purcell/plink/download.shtml) and point to the plink run file."; 
    echo "tcsh: use plink"
    echo "bash: use ./plink"
    exit 1
else if (! -e $SCRIPTPATH/beagle.jar) then
    echo "Please install Beagle 3 (http://faculty.washington.edu/browning/beagle/beagle.html#download) and copy the run file (beagle.3.0.4/beagle.jar) into $SCRIPTPATH/"; exit 1
else if (! -e $SCRIPTPATH/linkage2beagle.jar) then
    echo "Please copy linkage2beagle.jar included in the beagle 3.0.4 zip file (beagle.3.0.4/utility/linkage2beagle.jar) into $SCRIPTPATH/"; exit 1
else if (! -e $SCRIPTPATH/beagle2linkage.jar) then # We use beagle2linkage (Buhm, 8/13/12)
    echo "Please copy beagle2linkage.jar (http://faculty.washington.edu/browning/beagle_utilities/utilities.html) into $SCRIPTPATH/"; exit 1
else if (! -e $MERGE) then
    echo "Please copy merge_tables.pl (included with this package) into $SCRIPTPATH/"; exit 1

endif

# INPUTS
set INPUT=$1
set REFERENCE=$2
set OUTPUT=$3
set PLINK=$4


set JAVATMP=$OUTPUT.javatmpdir
mkdir -p $JAVATMP
alias plink '$PLINK --noweb --silent --allow-no-sex'
alias beagle 'java -Djava.io.tmpdir=$JAVATMP -Xmx$MEM\m -jar $SCRIPTPATH/beagle.jar'
alias linkage2beagle 'java -Djava.io.tmpdir=$JAVATMP -Xmx$MEM\m -jar $SCRIPTPATH/linkage2beagle.jar'
alias beagle2linkage 'java -Djava.io.tmpdir=$JAVATMP -Xmx$MEM\m -jar $SCRIPTPATH/beagle2linkage.jar'
alias allele2HLA_PED 'Rscript $SCRIPTPATH/allele2HLA_PED_by_COOK_20170622.R'
alias BGL2AllELES 'python $SCRIPTPATH/BGL2Alleles_for_merge.py'
alias MakeReference '$SCRIPTPATH/MakeReference.csh'
# Functions to run
set Make_hla_ped = 1
set Extract_Common_SNP = 1
set FLIP        = 1
set Merge_panel = 1

# SET PARAMETERS
set TOLERATED_DIFF = .15
set i = 1



set MHC=$INPUT.flap_checked

echo $REFERENCE
if ($Make_hla_ped) then
    echo "[$i] make_hla_ped."; @ i++
    BGL2AllELES $INPUT.bgl.phased $INPUT.alleles all  
    BGL2AllELES $REFERENCE.bgl.phased $REFERENCE.alleles all
        
    allele2HLA_PED $INPUT.alleles $INPUT.fam $INPUT.HLAPED
    allele2HLA_PED $REFERENCE.alleles $REFERENCE.fam $REFERENCE.HLAPED
    
endif

if ($Extract_Common_SNP) then
    echo "[$i] Extracting Common SNPs."; @ i++
    cut -f 2 $INPUT.bim > data1.snps_HLA.txt
    grep rs data1.snps_HLA.txt > data1.snps.txt
    cut -f 2 $REFERENCE.bim> data2.snps_HLA.txt
    grep rs data1.snps_HLA.txt > data2.snps.txt
    grep -f data1.snps.txt data2.snps.txt > Common.snps.txt
    
    
    plink --bfile $INPUT --extract Common.snps.txt --make-bed --out $MHC
endif
	
if ($FLIP) then
    echo "[$i] Performing SNP quality control."; @ i++

    # Identifying non-A/T non-C/G SNPs to flip
    echo "SNP 	POS	A1	A2" > $OUTPUT.tmp1
    cut -f2,4- $MHC.bim >> $OUTPUT.tmp1
    echo "SNP 	POSR	A1R	A2R" > $OUTPUT.tmp2
    cut -f2,4- $REFERENCE.bim >> $OUTPUT.tmp2
    $MERGE $OUTPUT.tmp2 $OUTPUT.tmp1 SNP |  grep -v -w NA > $OUTPUT.SNPS.alleles

    awk '{if ($3 != $6 && $3 != $7){print $1}}' $OUTPUT.SNPS.alleles > $OUTPUT.SNPS.toflip1
    plink --bfile $MHC --flip $OUTPUT.SNPS.toflip1 --make-bed --out $MHC.FLP

    # Calculating allele frequencies
    plink --bfile $MHC.FLP --freq --out $MHC.FLP.FRQ
    sed 's/A1/A1I/g' $MHC.FLP.FRQ.frq | sed 's/A2/A2I/g' | sed 's/MAF/MAF_I/g' > $OUTPUT.tmp

    mv $OUTPUT.tmp $MHC.FLP.FRQ
    $MERGE $REFERENCE.FRQ.frq $MHC.FLP.FRQ.frq SNP | grep -v -w NA > $OUTPUT.SNPS.frq
    sed 's/ /\t/g' $OUTPUT.SNPS.frq | awk '{if ($3 != $8){print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $9 "\t" $8 "\t" 1-$10 "\t*"}else{print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $8 "\t" $9 "\t" $10 "\t."}}' > $OUTPUT.SNPS.frq.parsed
    
    # Finding A/T and C/G SNPs
    awk '{if (($2 == "A" && $3 == "T") || ($2 == "T" && $3 == "A") || ($2 == "C" && $3 == "G") || ($2 == "G" && $3 == "C")){if ($4 > $7){diff=$4 - $7; if ($4 > 1-$7){corrected=$4-(1-$7)}else{corrected=(1-$7)-$4}}else{diff=$7-$4;if($7 > (1-$4)){corrected=$7-(1-$4)}else{corrected=(1-$4)-$7}};print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" diff "\t" corrected}}' $OUTPUT.SNPS.frq.parsed > $OUTPUT.SNPS.ATCG.frq

    # Identifying A/T and C/G SNPs to flip or remove
    awk '{if ($10 < $9 && $10 < .15){print $1}}' $OUTPUT.SNPS.ATCG.frq > $OUTPUT.SNPS.toflip2
    awk '{if ($4 > 0.4){print $1}}' $OUTPUT.SNPS.ATCG.frq > $OUTPUT.SNPS.toremove

    # Identifying non A/T and non C/G SNPs to remove
    awk '{if (!(($2 == "A" && $3 == "T") || ($2 == "T" && $3 == "A") || ($2 == "C" && $3 == "G") || ($2 == "G" && $3 == "C"))){if ($4 > $7){diff=$4 - $7;}else{diff=$7-$4}; if (diff > '$TOLERATED_DIFF'){print $1}}}' $OUTPUT.SNPS.frq.parsed >> $OUTPUT.SNPS.toremove
    awk '{if (($2 != "A" && $2 != "C" && $2 != "G" && $2 != "T") || ($3 != "A" && $3 != "C" && $3 != "G" && $3 != "T")){print $1}}' $OUTPUT.SNPS.frq.parsed >> $OUTPUT.SNPS.toremove
    awk '{if (($2 == $5 && $3 != $6) || ($3 == $6 && $2 != $5)){print $1}}' $OUTPUT.SNPS.frq.parsed >> $OUTPUT.SNPS.toremove

    # Making QCd SNP file
    plink --bfile $MHC.FLP --geno 0.2 --exclude $OUTPUT.SNPS.toremove --flip $OUTPUT.SNPS.toflip2 --make-bed --out $MHC.QC
    plink --bfile $MHC.QC --freq --out $MHC.QC.FRQ
    sed 's/A1/A1I/g' $MHC.QC.FRQ.frq | sed 's/A2/A2I/g' | sed 's/MAF/MAF_I/g' > $OUTPUT.tmp
    mv $OUTPUT.tmp $MHC.QC.FRQ.frq
    $MERGE $REFERENCE.FRQ.frq $MHC.QC.FRQ.frq SNP | grep -v -w NA > $OUTPUT.SNPS.QC.frq

    cut -f2 $OUTPUT.SNPS.QC.frq | awk '{if (NR > 1){print $1}}' > $OUTPUT.SNPS.toinclude

    echo "SNP 	POS	A1	A2" > $OUTPUT.tmp1
    cut -f2,4- $MHC.QC.bim >> $OUTPUT.tmp1

    $MERGE $OUTPUT.tmp2 $OUTPUT.tmp1 SNP | awk '{if (NR > 1){if ($5 != "NA"){pos=$5}else{pos=$2}; print "6\t" $1 "\t0\t" pos "\t" $3 "\t" $4}}' > $MHC.QC.bim

    # Recoding QC'd file as ped
    plink --bfile $MHC.QC --extract $OUTPUT.SNPS.toinclude --make-bed --out $MHC.QC.reorder
    plink --bfile $MHC.QC.reorder --recode --out $MHC.QC


	#extract data2 common SNPs
	cut -f 2 $MHC.QC.reorder.bim > commonSNPfor_data2.txt
	plink --bfile $REFERENCE --extract commonSNPfor_data2.txt --make-bed --out $REFERENCE.flap_checked.QC.reorder
	
    # Remove temporary files
    rm $OUTPUT.tmp1 $OUTPUT.tmp2
    rm $MHC.FLP*
    rm $MHC.QC.ped $MHC.QC.map
    rm $OUTPUT.SNPS.*
endif


if ($Merge_panel) then
    echo "[$i] Merge_panel."; @ i++
	cat  $INPUT.HLAPED $REFERENCE.HLAPED > Merge.HLAPED
	plink --bfile $MHC.QC.reorder --bmerge $REFERENCE.flap_checked.QC.reorder.bed $REFERENCE.flap_checked.QC.reorder.bim $REFERENCE.flap_checked.QC.reorder.fam --make-bed --out Merge_plink
    MakeReference Merge_plink Merge.HLAPED $OUTPUT plink
    

endif

