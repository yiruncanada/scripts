#!/bin/bash
#
#
path=$1
if [[ -z "$path" ]]
then
	echo "Usage: $0 <path>"
	exit 1
fi

if  ! ls "$path" > commands_stdout.log 2> /dev/null
then
	echo "Le dossier n'existe pas."
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
