#!/bin/bash

source=$1
destination=$2
dirArchive=$3


# Verify the number of arguments
if [[ ! $# -eq 3 ]]
then
	echo "Usage: $0 <source dossier> <destination dossier> <dirArchive dossier>"
	exit 1
fi

# Create these directories
mkdir -p "$destination"
mkdir -p "$dirArchive"


# Verify if the source directory is ~
if [[ "$source" == "$HOME" ]]
then
	echo "Le dossier source ne devrais pas le dossier personnel de l'utilisateur"
	exit 1
fi

# Verify le source directory contians at least one items
if [[ -z $(ls "$source") ]]
then
	echo "Le dossier source doit contenir au moins un fichier ou dossier"
	exit 1
fi

# Verify le source directory contians at least one file
if [[ -z $(ls -FR  "$source" | grep -v "/$") ]]
then
	echo "Le dossier source et ses sous-dossiers doivent contenir au moins un fichier."
	exit 1
fi

# Create file .tar.gz
if  tar -czf "$dirArchive/backup_$(basename "$source")_$(date +"%Y%m%d_%H%M%S").tar.gz" "$source" 
then 
	echo "L'archivage est bien fini."
else
	echo "Oups, la creation de l'archive echoue!"
	exit 1
fi

# Move source directory to destination directory
if  mv "$source" "$destination"
then
	echo "Le dossier source a été déplacé avec succès vers le dossier destination."
	exit 0
else
	echo "L'operation de bouger source dossier vers destination dossier est echoue!"
	exit 1
fi