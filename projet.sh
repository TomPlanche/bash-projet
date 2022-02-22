#!/usr/bin/env bash

# ============================================================================ #
#           Created by Tom Planche (http://github.com/TomPlanche)              #
#                         Licence Provided In Folder                           #
#                             2022 Bayonne, France                             #
# ============================================================================ #


# ============================================================================ #
#                      INITIALIZATION OF GLOBAL VARIABLES                      #
# ============================================================================ #
BLUE='\033[1;36m'
RED='\033[1;31m'
GRAY='\033[1;37m'
GRAY2='\033[0;37m'
GREEN='\033[1;32m'
NC='\033[0m'
TOM="----- "

UNDERLINE=`tput smul`
NOUNDERLINE=`tput rmul`

PATH_FILE_PATH="defaultPath.txt"
EXT_FILE_PATH="ext.txt"

VFS_PATH="$(cat $PATH_FILE_PATH)/VFS"


# ============================================================================ #
#                                   FUNCTIONS                                  #
# ============================================================================ #

function checkFile {
    [ -f $1 ]
}

function checkFolder {
    [ -d $1 ]
}

function create() {
    if !(checkFolder "$VFS_PATH")
    then
        mkdir $VFS_PATH
        mkdir "$VFS_PATH/Documents" "$VFS_PATH/Pictures" "$VFS_PATH/Videos" "$VFS_PATH/Music"

        mkdir "$VFS_PATH/Documents/Illustrator" "$VFS_PATH/Documents/Markdown" "$VFS_PATH/Documents/Word"

        echo "VFS Folder ${GREEN}created.$NC"
    else
        echo "${UNDERLINE}VFS already exists${NOUNDERLINE} at '$VFS_PATH'."
    fi
}

function delete() {
    if checkFolder $VFS_PATH
    then
        rm -R $VFS_PATH
        echo "VFS ${RED}deleted${NC}."
    else
        echo "VFS ${UNDERLINE}does not exits${NOUNDERLINE}."
    fi
}


function isIn() {
  if !(checkFolder "$VFS_PATH")
  then
    echo "${ROUGE}main.sh: isIn: ${NC}${GRIS2}The VFS folder does not exits.$NC$NOUNDERLINE"
    return 1
    exit 1
  else
    extension=".${1##*.}"

    toEcho="❌ $1 in not in VFS."
    toReturn=0

    lines=$(cat $EXT_FILE_PATH)

    for line in $lines
    do
      IFS=',' read -ra tab <<< "$line"

      ext=${tab[0]}

      extPath=${tab[1]}


      if grep -q "$extension" <<< "$ext"
      then
        if checkFile "$VFS_PATH/$extPath/$1"
        then
          toEcho="✅ at --> $extPath/$1"
          break
        fi
      else
        toReturn=1
      fi
    done

    echo $toEcho
    return $toReturn
  fi
}


function copieVerif() {

  extension=".${1##*.}"
  fileName="${1%%.*}"

  let cpt=1

  while true
  do
    if [ ! -f "$2/$1" ]
    then
      cp -va $1 "$2"
      break
    else

      if [ -f "$2/$fileName-$cpt$extension" ]
      then
        ((cpt ++))
      else
        cp -va $1 "$2/$fileName-$cpt$extension"
        break
      fi
    fi
  done
}

function copy() {
  if !(checkFile $1)
  then
    echo "main.sh: copy: "$1" this file does not exists"
  else
    extension=".${1##*.}"
    find=1

    lignes=$(cat $EXT_FILE_PATH)

    for ligne in $lignes
    do
      IFS=',' read -ra tab <<< "$ligne"

      ext=${tab[0]}
      cheminExt=${tab[1]}

      if grep -q "$extension" <<< "$ext"
      then
        copieVerif $1 "$VFS_PATH/${cheminExt}"
        find=0
        break
      fi
    done

    if [[ $find == 1 ]]
    then
      echo "Il n'existe pas de dossier pour ce type de fichiers,"
      echo "Voulez-vous déplacer ce fichier dans le dossier 'Random' : choix 1 ?"
      echo "ou voulez-vous créee un dossier spécial dans $VFS_PATH/Documents : choix 2 ?"
      echo

      while true; do
        read -p "(1 ou 2) : " -n 1
        echo
        [[ "$REPLY" != "1" && "$REPLY" != "2" ]] || break
      done

      if [[ $REPLY = 1 ]] ; then
        if (checkFolder $VFS_PATH/Documents/Random)
        then
          copieVerif $1 "$VFS_PATH/Documents/Random"
        else
          mkdir "$VFS_PATH/Documents/Random"
          copieVerif $1 "$VFS_PATH/Documents/Random"
        fi

      else
        echo
        read -p "Nom du nouveau Dossier : "
        dossier=$REPLY
        if [ -d $VFS_PATH/Documents/$dossier ]
        then
          echo "Ce dossier est déjà créé."
        else
          mkdir "$VFS_PATH/Documents/$dossier"
        fi

        echo "copieVerif ${1} $VFS_PATH/Documents/$dossier/${1}"
        copieVerif ${1} "$VFS_PATH/Documents/$dossier/"
        echo "$extension,/Documents/$dossier" >> $EXT_FILE_PATH
      fi
      break
    fi
  fi
}



# ============================================================================ #
#                                   MAIN                                       #
# ============================================================================ #
if [ $# -lt 1 ]
then
  echo "Not enough arguments."
elif [ $# -eq 1 ]
then
  case $1 in
    "-create" )
      echo "VFS Folder creation at ${VFS_PATH}."
      create
      ;;
    "-delete" )
      echo "VFS folder deletion."
      delete
      ;;
    "-where" )
      echo "'Where' needs at least one argument."
      ;;
    "-copy" )
      echo "'Where' needs at least one argument."
      ;;

  esac
else
  case $1 in
    "-where" )
      echo "${TOM}Checking for file(s) in VFS."
      for arg in $( eval echo {2..$#} )
        do
          isIn ${!arg}
        done
      ;;
    "-copy" )
      echo "${TOM}Copying file(s)."
      for arg in $( eval echo {2..$#} )
      do
        copy ${!arg}
      done
      ;;
  esac
fi
