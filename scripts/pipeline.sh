#Download all the files specified in data/filenames
urls=(
"https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.1s_sRNA.fastq.gz"
"https://bioinformatics.cnio.es/data/courses/decont/C57BL_6NJ-12.5dpp.1.2s_sRNA.fastq.gz"
"https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.1s_sRNA.fastq.gz"
"https://bioinformatics.cnio.es/data/courses/decont/SPRET_EiJ-12.5dpp.1.2s_sRNA.fastq.gz"
"https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"
)

for url in "${urls[@]}"; do
    bash scripts/download.sh "$url" data yes
done

# Download the contaminants fasta file, uncompress it, and filter to remove all small nuclear RNAs (función integrada en el script download.sh)

contaminants_url="https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz"

if [ ! -e "res/contaminants.fasta" ]; then
	bash scripts/download.sh "$contaminants_url" res yes 
else
	echo "The contaminants database is already downloaded. Skipping step."
fi

#Verificamos si existe el directorio (significaría que el genoma está indexado). Si no, lo creamos.
if [ ! -d "res/contaminants_index" ]; then
	mkdir -p "res/contaminants_index"
fi

if [ ! -n "$(ls -A res/contaminants_index/ )" ]; then 
	bash scripts/index.sh data/contaminants.fasta  res/contaminants_index
else
	echo "Contaminants already indexed."


fi


# Merge the samples into a single file. Verificamos que exista el directorio, y, si no, lo creamos.

if [ ! -d "out/merged" ]; then
	mkdir -p "out/merged"
fi

#Si los archivos ya están fusionados, nos saltamos este paso.
echo "Merging..."
if [ ! -n "$(ls -A out/merged/ )" ]; then
	for sid in $(ls data/*.fastq |cut -d "." -f1 | sed 's:data/::' | sort | uniq); do
                bash scripts/merge_fastqs.sh data out/merged $sid
        done
else
	echo "Files already merged. Skipping merging."

fi

#Run cutadapt for all merged files. Primero necesitamos comprobar si los directorios existen. Si no, los creamos.

if [ ! -d "log/cutadapt" ]; then
        mkdir -p "log/cutadapt"
fi

if [ ! -d "out/trimmed" ]; then 
        mkdir -p "out/trimmed"
fi
#Si ya hemos eliminado los adaptadores, nos saltamos este paso.
echo "Trimming adapters..."
if [ -z "$(ls -A log/cutadapt/ )" ]
then
        for filename in out/merged/*.fastq.gz
        do
                file="$(basename "$filename" .fastq.gz)"
                echo "Before cutadapt: $filename"
                cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
                        -o out/trimmed/$file.trimmed.fastq.gz  out/merged/$file.fastq.gz > log/cutadapt/$file.log
                echo "After cutadapt: $filename"        
done

else
        echo "Skipping cutadapt."

fi

#Run STAR for all trimmed files. Comprobamos si existe el directorio, y si no, lo creamos.

if [ ! -d "out/star" ]; then
        mkdir -p "out/star"
fi

#Verificamos que la operación no se haya realizado ya.
echo "Running STAR..."
#if [ ! -n "$(ls -A out/star/)" ]; then
if [ -n "find out/trimmed -type f -name '*.fastq.gz')" ]
then 
        for fname in out/trimmed/
        do
                sampleid="$(basename "$fname" .trimmed.fastq.gz)"
                if [ ! -d "out/star/$sampleid" ]
                then
                        mkdir -p "out/star/$sampleid"
                fi

                STAR --runThreadN 4 --genomeDir res/contaminants_index \
                      --outReadsUnmapped Fastx --readFilesIn "$fname" \
                      --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sampleid/
        done

else
        echo "No files found in out/trimmed. Skipping STAR."
fi


#Create a log file containing information from cutadapt and star logs (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci

#!/bin/bash

if [ ! -e "log/pipeline.log" ]; then
    touch "log/pipeline.log"

    # Iterate over files in log/cutadapt/
    for file in log/cutadapt/*; do
        if [ ! -f "$file" ]; then
            echo "Archivo $file" >> "log/pipeline.log"
            grep -E "Total basepairs processed|Reads with adapters" "$file" >> "log/pipeline.log"
            echo "........................" >> "log/pipeline.log"
        fi
    done

    # Iterate over subdirectories in out/star/
    for dir in out/star/*; do
        if [ -d "$dir" ]; then
            file="$dir/Log.final.out"
            if [ ! -f "$file" ]; then
                echo "Archivo $file" >> "log/pipeline.log"
                grep -E "Uniquely mapped reads %|% of reads mapped to muliple loci|% of reads mapped to too many loci" "$file" >> "log/pipeline.log"
                echo "...................." >> "log/pipeline.log"
            fi
        fi
    done
fi

