#!/usr/bin/env bash

# Le chemin vers le fichier source d'URLs : ex : ../URLs/es.txt
chemin_urls=$1
# Le fichier HTML qui va contenir le tableau des URLs : exemple, ici tab_es.html
fic_tab=$2
# La langue choisie : fr, en, es (français, anglais ou espagnol)
langue=$3

# Un exemple d'utilisation serait donc : ./miniprojet.sh ../URLs/es.txt tab_es.html es


if [ $# -ne 3 ]; then
	echo "On attend 3 arguments exactement : veuillez donner un chemin valide vers le fichier texte source d'URLs, le nom du fichier HTML dans lequel stocker le tableau d'URLs, et la langue choisie"
	exit
# Vérifie si c'est un fichier, et pas un dossier par exemple
# $1 ou $chemin_urls	
elif [ -f $1 ]; then 
	echo "on a bien un fichier source"
else 
	echo "on attend un fichier source d'URLs qui existe"
	exit
fi	
# Il faut que le dossier '../tableaux/' existe au préalable, car c'est dans ce dossier qu'on va modifier le fichier HTML

basename=$(basename -s .txt $chemin_urls)

# Faut-il prendre en compte le pluriel du mot ? Les différentes façons d'écrire le mot ? Oui
if [[ $langue == 'fr' ]]; then
	mot="([ÉEé][Vv][Oo][Ll][Uu][Tt][Ii][Oo][Nn][Ss]?)"
elif [[ $langue == 'en' ]]; then
	mot="([Ee][Vv][Oo][Ll][Uu][Tt][Ii][Oo][Nn][Ss]?)"
elif [[ $langue == 'es' ]]; then
	mot="([Ee][Vv][Oo][Ll][Uu][Cc][Ii][ÓOóo][Nn][Ee]?[Ss]?)"
fi
# if [[ $langue == 'fr' ]]; then
# 	  mot="([ÉEé]volution)"
# elif [[ $langue == 'en' ]]; then
# 	  mot="([Ee]volution)"
# elif [[ $langue == 'es' ]]; then
#	  mot="([Ee]volución)"
# fi

echo 	"<html>
	<head>
		<meta charset=\"UTF-8\" />
		<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
		<title>Tableau des URLs</title>
	</head>
	<body>
		<section>
			<div class="container">
				<h1 class=\"title\" style=\"text-align: center;\">Tableau URLs $basename</h1>
				<table class=\"table is-bordered is-striped is-narrow is-hoverable\" style=\"margin: auto\">
					<thead style=\"background-color: #b888e1;\"><tr><th style=\"color: #ffffff\">Ligne</th><th style=\"color: #ffffff\">Code HTTP</th><th style=\"color: #ffffff\">URL</th><th style=\"color: #ffffff\">Encodage</th><th style=\"color: #ffffff\">HTML</th><th style=\"color: #ffffff\">Dump</th><th style=\"color: #ffffff\">Compte</th><th style=\"color: #ffffff\">Contextes</th><th style=\"color: #ffffff\">Concordances</th></thead>" > "../tableaux/$fic_tab"
	# On pourra rajouter plus tard d'autres catégories au tableau, comme les aspirations, dumps, occurences, contextes, concordance, etc.S


lineno=0

while read -r URL;
do
	((lineno++)); # ou lineno=$(($lineno + 1))

	echo -e "\tURL : $URL";
	# Réponse HTTP
	code=$(curl -s -I -L -w "%{http_code}" -o /dev/null $URL)
		
	# Récupération de l'encodage
	charset=$(curl -s -I -L -w "%{content_type}" $URL | grep -P -o "charset=\S+" | cut -d"=" -f2 | tail -n 1)

	# Déterminer le résultat en fonction du code de réponse HTTP
	if [ $code -eq 200 ]; then
		result="Valide"
	else
		result="Erreur"
	fi

	if [[ -z $charset ]]; then
		echo -e "\tencodage non détecté.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	# pour transformer les 'utf-8' en 'UTF-8' : on sait jamais
	charset=$(echo $charset | tr "[a-z]" "[A-Z]")

	# On va s'occuper de l'aspiration et du dump
	if [[ $code -eq 200 ]]; then
		aspiration=$(curl $URL)

		echo $aspiration

		if [[ $charset == 'UTF-8' ]]; then
			dump=$(curl $URL | iconv -f UTF-8 -t UTF-8//IGNORE | lynx -stdin  -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8)
		else
			dump=$(curl $URL | iconv -f $charset -t UTF-8//IGNORE | lynx -stdin  -accept_all_cookies -dump -nolist -assume_charset=utf-8 -display_charset=utf-8)
		fi
	else
		echo -e "\ton veut un code = 200 : code != 200 alors utilisation d'un dump vide"
		dump=""
		charset=""
	fi

	echo "$aspiration" > "../aspirations/$langue/$basename-$lineno.html"

	echo "$dump" > "../dumps-text/$langue/$basename-$lineno.txt"

	# L'option -o va afficher une occurence par ligne de résultat : il suffit juste de prendre la sortie et de compter le nombre de ligne
	occurences=$(grep -E -i -o $mot "../dumps-text/$langue/$basename-$lineno.txt" | wc -l)

	# grep -C aussi pour le contexte (contexte : les lignes qui entourent le motif, le mot)
	grep -E -i -A 2 -B 2 $mot "../dumps-text/$langue/$basename-$lineno.txt" > "../contextes/$langue/$basename-$lineno.txt" 

	sh ./concordancier.sh $langue "../dumps-text/$langue/$basename-$lineno.txt" $mot > "../concordances/$langue/$basename-$lineno.html"
		



	# Les tabulations dans le echo sont là pour respecter l'indentation dans le fichier HTML qui stocke les URLs sous forme de tableau : pas obligatoires mais plus lisible avec
	echo "					<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$langue/$basename-$lineno.html">html</a></td><td><a href="../dumps-text/$langue/$basename-$lineno.txt">text</a></td><td>$occurences</td><td><a href="../contextes/$langue/$basename-$lineno.txt">contexte</a></td><td><a href="../concordances/$langue/$basename-$lineno.html">concordance</a></td></tr>" >> "../tableaux/$fic_tab"


done < "$chemin_urls"
# done < $chemin_urls

echo "			</table>
			</div>
		</section>
	</body>
</html>" >> "../tableaux/$fic_tab"