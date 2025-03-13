#!/bin/bash
#
#
path=$1
if [[ -z "$path" ]]
then
	echo "Usage: $0 <path>"
	exit 1
fi

if [[ -d "$path" ]]
then
	echo "Le path ${path} no correspond pas a un dossier."
	exit 1
fi

if [[ -z $(ls "$path")  ]] 
then
	echo " Le dossier est vide. "
	exit 1
fi

if ls "$path"
then 
	exit 0
fi
