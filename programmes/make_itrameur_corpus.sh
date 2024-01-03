#!/usr/bin/env bash

# Exemple d'execution : 
	# ./make_itrameur_corpus.sh contextes/es es
	# ./make_itrameur_corpus.sh dumps-text/es es

# Ajouter le contenu de tous les dumps ou contextes de toutes les langues dans un fichier dump.txt ou contexte.txt, en écrasant son contenu ou en le créant s'il n'existe pas : 
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

if [[ $dossier == "contextes/$langue" ]]; then
	echo "<lang=\"$langue\">" > "../itrameur/contexte-$langue.txt"
elif [[ $dossier == "dumps-text/$langue" ]]; then
	echo "<lang=\"$langue\">" > "../itrameur/dump-$langue.txt"
fi

# Pour chaque fichier dans le dossier et la langue choisis
for chemin in $(ls ../$dossier/$langue-*.txt)
do
  # Extraction du nom du fichier sans l'extension .txt
	page_n=$(basename -s .txt $chemin)

	if [[ $dossier == "contextes/$langue" ]]; then
		echo "<page=\"$page_n\">" >> "../itrameur/contexte-$langue.txt"
		echo "<text>" >> "../itrameur/contexte-$langue.txt"
	elif [[ $dossier == "dumps-text/$langue" ]]; then
		echo "<page=\"$page_n\">" >> "../itrameur/dump-$langue.txt"
		echo "<text>" >> "../itrameur/dump-$langue.txt"
	fi

  # Lit le contenu du fichier courant
	contenu=$(cat $chemin)

  # On gère les entites HTML/XML avec des substitutions pour ne pas avoir d'erreurs d'interprétation
	contenu=$(echo "$contenu" | sed -E "s/&/&amp;/g")
	contenu=$(echo "$contenu" | sed -E "s/</&lt;/g")
	contenu=$(echo "$contenu" | sed -E "s/>/&gt;/g")

	# Il faut gérer les différents motifs rencontrés pour le mot qui nous intéresse (par exemple les majusculesn le pluriel, etc.)
	if [[ $langue == 'en' ]]; then
		contenu=$(echo "$contenu" | sed -E "s/\"?[Ee][Vv][Oo][Ll][Uu][Tt][Ii][Oo][Nn][Ss]?\"?/evolution/gI")
	elif [[ $langue == 'fr' ]]; then
		contenu=$(echo "$contenu" | sed -E "s/\"?[ÉEé][Vv][Oo][Ll][Uu][Tt][Ii][Oo][Nn][Ss]?\"?/évolution/gI")
	elif [[ $langue == 'es' ]]; then
		contenu=$(echo "$contenu" | sed -E "s/\"?[Ee][Vv][Oo][Ll][Uu][Cc][Ii][ÓOóo][Nn][Ee]?[Ss]?\"?/evolución/gI")
	fi


	if [[ $dossier == "contextes/$langue" ]]; then
		echo "$contenu" >> "../itrameur/contexte-$langue.txt"
		echo "</text>" >> "../itrameur/contexte-$langue.txt"
		echo "</page> §" >> "../itrameur/contexte-$langue.txt"
	elif [[ $dossier == "dumps-text/$langue" ]]; then
		echo "$contenu" >> "../itrameur/dump-$langue.txt"
		echo "</text>" >> "../itrameur/dump-$langue.txt"
		echo "</page> §" >> "../itrameur/dump-$langue.txt"
	fi

done

if [[ $dossier == "contextes/$langue" ]]; then
	echo "</lang>" >> "../itrameur/contexte-$langue.txt"
elif [[ $dossier == "dumps-text/$langue" ]]; then
	echo "</lang>" >> "../itrameur/dump-$langue.txt"
fi

# On ne s'occupe pas de l'indentation des balises