# This script should download the file specified in the first argument ($1),
# place it in the directory specified in the second argument ($2),
# and *optionally*:
# - uncompress the downloaded file with gunzip if the third
#   argument ($3) contains the word "yes"
# - filter the sequences based on a word contained in their header lines:
#   sequences containing the specified word in their header should be **excluded**
#
# Example of the desired filtering:
#
#   > this is my sequence
#   CACTATGGGAGGACATTATAC
#   > this is my second sequence
#   CACTATGGGAGGGAGAGGAGA
#   > this is another sequence
#   CCAGGATTTACAGACTTTAAA
#
#   If $4 == "another" only the **first two sequence** should be output
cd ~/decont/data

wget https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz
wget https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.2s_sRNA.fastq.gz
wget https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.1s_sRNA.fastq.gz
wget https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.2s_sRNA.fastq.gz

gunzip https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz
gunzip https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.2s_sRNA.fastq.gz 
gunzip https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.1s_sRNA.fastq.gz 
gunzip https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.2s_sRNA.fastq.gz

cd ~/decont/res

wget https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz | gunzip https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz
