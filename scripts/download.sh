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

#Definimos los argumentos que debemos indicar a la shell. 
url="$1"
destination_dir="$2"
uncompress="$3"

#Extraer el nombre del archivo de la URL.
filename="$(basename "$url")"
cat filename
#Descargamos el archivo
wget "$url" -P "$destination_dir"

#Verificar si se debe descomprimir. En caso de que sí, además se eliminan todas las entradas de small nuclear RNA.

if [ "$uncompress" = "yes" ]; then
	if [ "${filename##*.}" = "gz" ]; then
		echo "Intentando descomprimir: $destination_dir/$filename"
		gunzip "$destination_dir/$filename"
	else
		echo "El fichero no está comprimido."
	fi
fi

