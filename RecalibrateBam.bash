#!/bin/bash

ls ../Data/RealignedBams * | grep _realigned.bam$ > temp.txt

mkdir ../Data/RecalTables
mkdir ../Data/PostRecalTables
mkdir ../Data/RecalPlots
mkdir ../Data/RecalBams

while read realigned; do
        name=${realigned%_realigned.bam}
        java -jar ./GenomeAnalysisTK.jar -nct 24 \
                -T BaseRecalibrator \
                -R ../Data/human_g1k_v37.fasta \
                -I ../Data/Dedup/${realigned} \
                -knownSites ../Data/Indels.vcf \
		-knownSites ../Data/dbsnp_138.b37.vcf \
                -o ../Data/RecalTables/${name}_recal.table

        java -jar ./GenomeAnalysisTK.jar -nct 24 \
                -T BaseRecalibrator \
                -R ../Data/human_g1k_v37.fasta \
                -I ../Data/Dedup/${realigned} \
                -knownSites ../Data/Indels.vcf \
		-knownSites ../Data/dbsnp_138.b37.vcf \
		-BQSR ../Data/RecalTables/${name}_recal.table               
		-o ../Data/PostRecalTables/${name}_postrecal.table
	
	java -jar ./GenomeAnalysisTK.jar \
                -T AnalyzeCovariates \
                -R ../Data/human_g1k_v37.fasta \
		-before ../Data/RecalTables/${name}_recal.table               
		-after ../Data/PostRecalTables/${name}_postrecal.table
		-plots ../Data/RecalPlots/${name}_recal_plot.pdf
	
	java -jar ./GenomeAnalysisTK.jar -nct 24 \
                -T PrintReads \
		-R ../Data/human_g1k_v37.fasta \                
		-I ../Data/Dedup/${realigned} \
		-BQSR ../Data/RecalTables/${name}_recal.table           
		-o ../Data/RecalBams/${name}_recal.bam

done< temp.txt

rm temp.txt
