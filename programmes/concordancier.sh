#!/usr/bin/env bash

langue=$1 # fr, en, es
fic_text=$2
motif=$3

if [[ $# -ne 3 ]]; then
	echo "Ce programme demande exactement trois arguments."
	echo "Utilisation : $0 <langue> <fichier> <motif>"
	exit
fi

if [[ ! -f $fic_text ]]; then
  echo "Il n'y a pas de fichier $fic_text"
  exit
fi

if [[ -z $motif ]]; then
  echo "Motif vide"
  exit
fi

if [[ $langue != 'fr' && $langue != "en" && $langue != "es" ]]; then
    echo "Langue acceptée : fr (français), en (anglais) ou es (espagnol)"
    exit
fi

echo 	"""
<html>
  <html lang=\"$langue\">
		<head>
			<meta charset=\"UTF-8\" />
			<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
			<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css\">
			<title>Concordances</title>
		</head>
		<body>
			<section>
				<h1 class=\"title\" style=\"text-align: center; \">Concordances</h1>
					<table class=\"table is-bordered is-striped is-narrow is-hoverable is-fullwidth\">
						<thead style=\"background-color: #b888e1;\">
						<tr>
						<th class=\"has-text-right\" style=\" color: #ffffff\">Contexte Gauche</th>
						<th style=\" color: #ffffff\">Cible</th>
						<th class=\"has-text-left\" style=\" color: #ffffff\">Contexte Droit</th>
						</tr>
						</thead>
						<tbody>
									"""

# Un contexte gauche et un contexte droit de 4 mots maximum : suffisant ? A voir, de toute façon on pourra toujours modifier plus tard 
grep -E -i -o "(\w+\W+){0,4}$motif(\W+\w+){0,4}" $fic_text | sed -E -r "s/(.*)$motif(.*)/<tr><td class=\"has-text-right\">\1<\/td><td class=\"has-text-danger\">\2<\/td><td class=\"has-text-left\">\3<\/td><\/tr>/"


echo "
						</tbody>
					</table>
			</section>
		</body>
</html>
"