#!/usr/bin/env bash

# Exemple d'execution : 
	# ./make_itrameur_corpus.sh contextes es
	# ./make_itrameur_corpus.sh dumps-text es

# Ajouter le contenu d'un fichier dans un autre : 
	# cat ../itrameur/dump-*.txt > ../itrameur/dump.txt OU 
	# cat ../itrameur/contexte-*.txt > ../itrameur/contexte.txt
# dump.txt et contexte.txt représentant respectivement tous les dumps et les contextes de tous les fichiers des 3 langues


if [[ $# -ne 2 ]]; then
	echo "On attend 2 arguments exactement : le nom du dossier (pas le chemin) et la langue (en, fr, es)"
  exit
fi

# dumps-text OU contextes
dossier=$1
# fr, en, es
langue=$2

# Crée ou réecrit avec > le fichier dans le dossier itrameur selon dumps-text ou contextes

if [[ $dossier == 'contextes' ]]; then
	echo "<lang=\"$langue\">" > "../itrameur/contexte-$langue.txt"
elif [[ $dossier == 'dumps-text' ]]; then
	echo "<lang=\"$langue\">" > "../itrameur/dump-$langue.txt"
fi

# Pour chaque fichier dans le dossier et la langue choisis
for chemin in $(ls ../$dossier/$langue-*.txt)
do
  # Extraction du nom du fichier sans l'extension .txt
	page_n=$(basename -s .txt $chemin)

	if [[ $dossier == 'contextes' ]]; then
		echo "<page=\"$page_n\">" >> "../itrameur/contexte-$langue.txt"
		echo "<text>" >> "../itrameur/contexte-$langue.txt"
	elif [[ $dossier == 'dumps-text' ]]; then
		echo "<page=\"$page_n\">" >> "../itrameur/dump-$langue.txt"
		echo "<text>" >> "../itrameur/dump-$langue.txt"
	fi

  # Lit le contenu du fichier courant
	contenu=$(cat $chemin)

  # On gère les entites HTML/XML avec des substitutions pour ne pas avoir d'erreurs d'interprétation
	contenu=$(echo "$contenu" | sed -E "s/&/&amp;/g")
	contenu=$(echo "$contenu" | sed -E "s/</&lt;/g")
	contenu=$(echo "$contenu" | sed -E "s/>/&gt;/g")

	if [[ $dossier == 'contextes' ]]; then
		echo "$contenu" >> "../itrameur/contexte-$langue.txt"
		echo "</text>" >> "../itrameur/contexte-$langue.txt"
		echo "</page> §" >> "../itrameur/contexte-$langue.txt"
	elif [[ $dossier == 'dumps-text' ]]; then
		echo "$contenu" >> "../itrameur/dump-$langue.txt"
		echo "</text>" >> "../itrameur/dump-$langue.txt"
		echo "</page> §" >> "../itrameur/dump-$langue.txt"
	fi

done

if [[ $dossier == 'contextes' ]]; then
	echo "</lang>" >> "../itrameur/contexte-$langue.txt"
elif [[ $dossier == 'dumps-text' ]]; then
	echo "</lang>" >> "../itrameur/dump-$langue.txt"
fi

# On ne s'occupe pas de l'indentation des balises