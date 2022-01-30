#!/usr/bin/env bash

v="VFS"

BLEU='\033[1;36m'
ROUGE='\033[1;31m'
GRIS='\033[1;37m'
GRIS2='\033[0;37m'
VERT='\033[1;32m'
NC='\033[0m'

UNDERLINE=`tput smul`
NOUNDERLINE=`tput rmul`

base="projet/VFS"

CHEM_FICH="/Users/tom_planche/Desktop/BUT/R1.04/projet"
FICHIER="$CHEM_FICH/extension.txt"




# Création des dossiers (couche par couche pour aider à la modification)
function create() {
  mkdir $v
  mkdir "$v/Documents" "$v/Images" "$v/Musique" "$v/Videos"
  mkdir "$v/Documents/Word" "$v/Documents/LibreOffice" "$v/Documents/Illustrator"
  touch "$v/Documents/Word/document1.doc" "$v/Documents/LibreOffice/document.odt" "$v/Documents/Illustrator/graph.ai"
  echo "$v ${UNDERLINE}${GRIS}créé.$NC${NOUNDERLINE}"
}


# Suppression totale du $v
function delete() {
  # Supprime récursisvement (d'ou le -r) $v
  rm -r $v
  echo "$v $ROUGE${UNDERLINE}supprimé.$NC$NOUNDERLINE"
}


# Vérifie si un fichier est présent dans $v
function isIn() {
  if [ ! -d "$v" ] ; then
    echo "${ROUGE}projet.sh: isIn: ${NC}${GRIS2}Le dossier de sauvegarde n'est pas crée.$NC$NOUNDERLINE"
    return 1
    exit 1
  else
    # Récupère l'extension du fichier.
    extension=".${1##*.}"

    # Variable qui prendra le chemin du fichier si il est trouvé, sinon
    aEcho="${ROUGE}projet.sh: isIn: ${NC}$1 n'est pas présent dans ce dossier."
    aReturn=0

    # Switch permettant différents traitements selon l'extension
    cpt=0

    lignes=$(cat $FICHIER)

    for ligne in $lignes
    do
      IFS=',' read -ra tab <<< "$ligne"

      ext=${tab[0]}
      cheminExt=${tab[1]}

      if [[ $extension == *$ext* ]] ; then
        aEcho="$cheminExt/$1"
        break;
      else
        aReturn=1
      fi
      # echo "${cheminExt[${cpt}]}/$1"
      ((cpt++))
    done
    # On finit par affichier le chemin s'il existe, sinon la phrase "Ce fichier n'est pas présent dans ce dossier."
    echo $aEcho
    return $aReturn
  fi
}


# Vérifie lors d'une copie si le fichier existe et modifie son nom si c'est le cas
function copieVerif() {
  # Récupère l'extension du fichier.
  extension=".${1##*.}"
  # Récupère le nom du fichier sans l'extension.
  nomFichier="${1%%.*}"

  # Compteur permettant d'énumerer les copies faites.
  let cpt=1

  # Boucle while infinie vérifiant s'il existe un fichier copie n°cpt
  while : ; do
    if [ ! -f "$2/$1" ] ; then
      cp -va $1 "$2"
      break
    else
      # Si le fichier (d'ou le -f) copie n°cpt existe, on augmente le cpt
      if [ -f "$2/$nomFichier-$cpt$extension" ] ; then
        ((cpt ++))
      # Sinon, on crée le fichier copie n°cpt
      else
        # -v explique quel fichier va ou exemple `TP7-copie -> DossierSauvegarde/TP7-copie`
        # -a conserve les liens et les propriétés des fichiers
        cp -va $1 "$2/$nomFichier-$cpt$extension"
        # Sortie de la boucle while
        break
      fi
    fi
  done
}


# Copie un fichier avec appel de 'copieVerif'
function copy() {
  # Si le fichier n'exite pas
  if [ ! -f $1 ] ; then
    echo "projet.sh: copy: "$1" ce fichier n'existe pas"
  # Sinon
  else
    extension=".${1##*.}"
    trouvee=1

    lignes=$(cat $FICHIER)

    for ligne in $lignes
    do
      IFS=',' read -ra tab <<< "$ligne"

      ext=${tab[0]}
      cheminExt=${tab[1]}


      if [[ $extension == *$ext* ]] ; then
        copieVerif $1 "$CHEM_FICH/$v${cheminExt}"
        trouvee=0
        break
      fi
    done

    if [[ $trouvee == 1 ]] ; then
      echo "Il n'existe pas de dossier pour ce type de fichiers,"
      echo "Voulez-vous déplacer ce fichier dans le dossier 'Random' : choix 1 ?"
      echo "ou voulez-vous créee un dossier spécial dans $v/Documents : choix 2 ?"
      echo
      # Boucle tant que assurant que la réponse saisie par l'utilisateur sera toujour 1 ou 2.
      while true; do
        # On utilise read afin de récupérer une saisie de l'utilisateur
        # -p est utilisé afin de 'prompt' = affichier la phrase avant la saisie
        # -n est utilisé afin de préciser que la saisie sera d'un seul caractère
        read -p "(1 ou 2) : " -n 1
        # echo permettant un saut à la ligne, esthétique
        echo
        # Si la réponse est 1 ou 2, on break sinon on boucle encore
        [[ "$REPLY" != "1" && "$REPLY" != "2" ]] || break
      done
      # Si la saisie est '1'
      if [[ $REPLY = 1 ]] ; then
        # On déplace le fichier dans le dossier 'Random'
        if [ -d $v/Documents/Random ] ; then
          copieVerif $1 "/Documents/Random"
        else
          mkdir "$v/Documents/Random"
          copieVerif $1 "/Documents/Random"
        fi
      # Si la saisie est '2'
      else
        # echo permettant un saut à la ligne, esthétique
        echo
        # On utilise read afin de récupérer une saisie de l'utilisateur
        # -p est utilisé afin de 'prompt' = affichier la phrase avant la saisie
        # -n est utilisé afin de préciser que la saisie sera d'un seul caractère
        read -p "Nom du nouveau Dossier : "
        # 'dossier' <- saisie
        dossier=$REPLY

        if [ -d $v/Documents/$dossier ] ; then
          echo "Ce dossier est déjà créé."
        else
          # Création du dosser 'dossier'
          mkdir "$v/Documents/$dossier"
        fi
        # Copie du fichier dans le dossier 'dossier'
        echo "copieVerif ${1} $v/Documents/$dossier/${1}"
        copieVerif ${1} "/Documents/$dossier/"
        echo "$extension,/Documents/$dossier" >> extension.txt
      fi
      break
    fi
  fi
}


# Vérifie l'intégrité du $v
function check() {
  # base="/Users/tom_planche_mbpm1/Desktop/BUT/R1.04/projet/VFS"
  base="VFS"
  if [ ! -d $base ] ; then
    echo "PasDeDossierVFS"
    exit 1
  fi
  # Compteur permettant d'accéder à la variable étant au même index.
  lignes=$(cat $FICHIER)

  for ligne in $lignes
  do
    IFS=',' read -ra tab <<< "$ligne"

    ext=${tab[0]}
    cheminExt=${tab[1]}

    if [ "$(ls -A $base$cheminExt)" ] ; then
      cd $base$cheminExt
      for fichier in *
      do
        #Si l'extension est dans la case n°cpt de tableau2
          if [[ ! ${ext} == *".${fichier##*.}"* ]] ; then
            echo "projet.sh: check: $base$cheminExt/$fichier n'est pas au bon endroit."
            echo "FAIL !"
            while true; do
              read -p "Voulez-vous déplacer le fichier ou le supprimer ? (d/s) : " -n 1
              echo
              [[ "$REPLY" != "d" && "$REPLY" != "s" ]] || break
            done
            if [[ $REPLY = "d" ]] ; then
              copy "$CHEM_FICH/$base$cheminExt/$fichier"
              rm "$fichier"
            else
              rm $fichier
            fi
          fi
      done
      cd $OLDPWD
    fi

    # # Vérifie si le dossier n'est pas vide
    # if [ "$(ls -A $base$cheminExt)" ] ; then
    #   # Parcours de tous les fichiers
    #   for fichier in *
    #   do
    #     # Si l'extension est dans la case n°cpt de tableau2
    #     if [[ ! ${ext} == *".${fichier##*.}"* ]] ; then
    #       echo "projet.sh: check: $base$cheminExt/$fichier n'est pas au bon endroit."
    #       echo "FAIL !"
    #       while true; do
    #         read -p "Voulez-vous déplacer le fichier ou le supprimer ? (d/s) : " -n 1
    #         echo
    #         [[ "$REPLY" != "d" && "$REPLY" != "s" ]] || break
    #       done
    #       if [[ $REPLY = "d" ]] ; then
    #         echo "---> $fichier"
    #         copy $fichier
    #         rm $base$cheminExt/$fichier
    #       else
    #         rm $base$cheminExt/$fichier
    #       fi
    #     fi
    #   done
    # fi
  done

  echo "VALIDE !"
}


# Si il ya plus de 0 argument
if [ $# -gt 0 ] ; then
  # Si l'argument commence par un '-' c'est que c'est une instruction
  if [ ${1:0:1} = "-" ] ; then
    # Switch permettant différents traitements selon l'instruction appelée
    case ${1:1} in
      # Si l'instruction est 'create'
      "create" )
        # S'il n'y a pas déjà un dossier $v, on le crée
        if [ ! -d "$v" ] ; then
          create
        # S'il existe, on propose à l'utilisateur de réécrire dessus ou de le laisser.
        else
          # Boucle while impliquant que la saisie de l'utilisateur sera obligatoirement 'o' ou 'n'.
          while true; do
              # On utilise read afin de récupérer une saisie de l'utilisateur
              # -p est utilisé afin de 'prompt' = affichier la phrase avant la saisie
              # -n est utilisé afin de préciser que la saisie sera d'un seul caractère
              read -p "projet.sh: create: existe déja, voulez vous le supprimer et recréer ? (o/) : " -n 1
              echo
              [[ "$REPLY" != "o" && "$REPLY" != "n" ]] || break
          done
          # Si la saisie est un o (majuscule ou non)
          if [[ $REPLY = "o" ]] ; then
            # Appel de la fonction 'delete'
            delete
            # Appel de la fonction 'create'
            create
          fi
        fi
        ;;
      # Si l'instruction est 'copy'
      "copy" )
        if [[ ! $# -gt 1 ]] ; then
          echo "projet.sh: copy: ${ROUGE}il manque un argument.${NC} Se référer au guide d'utilisation 'projet.sh -h'"
        else
          if [ ! -d $v ] ; then
            echo "projet.sh: copy: Il faut d'abord créer le VFS."
          else
            for arg in $( eval echo {2..$#} )
            do
              copy ${!arg}
            done
          fi
        fi

        ;;
      # Si l'instruction est 'create'
      "delete" )
        # Incrémentation de 'cpt' permettant l'accès à l'argument suivant
        ((cpt ++))
        # S'il y a moins de deux arguments, on supprime tout
        if [ $# -lt 2 ] ; then
          # Si le dossier existe
          if [ ! -d $v ] ; then
            echo "projet.sh: delete: Il n'y a rien à supprimer."
          else
            # Boucle tant que assurant que la réponse saisie par l'utilisateur sera toujour 'o' ou 'n'.
            while true; do
                read -p "Êtes-vous sûr de tout supprimer ? (o/n) : " -n 1
                echo
                [[ "$REPLY" != "n" && "$REPLY" != "o" ]] || break
            done
            # Si la saisie est un 'o'
            if [ $REPLY = "o" ] ; then
              # Suppression de $v
              delete
              # Sortie du programme
              exit 1
            elif [ $REPLY = "n" ] ; then
              exit 1
            fi
          fi
        # S'il y a plus de deux arguments, alors le fichier est passé en tant qu'argument
        else
          for arg in $( eval echo {2..$#} )
          do
            a=$(isIn ${!arg})
            if [ $? == 1 ] ; then
              echo "projet.sh: delete: ${!arg} n'existe pas"
            # Sinon
            else
              # chemin <- string affiché par la fonction 'isIn' qui est son chemin.
              chemin=$(isIn ${!arg})
              if [[ $? == 0 ]] ; then
                # Suppression du fichier
                echo "$chemin supprimé"
                rm $v$chemin
              else
                echo "projet.sh: delete: Ce fichier n'est pas présent dans $v."
              fi
            fi
          done
        fi
        ;;
      # Si l'instruction est 'where'
      "where" )
        if [ $# -lt 2 ] ; then
          echo "${ROUGE}projet.sh : where:$NC Il manque un argument, 'sh projet -h'"
        else
          # Appel de la fonction 'isIn'
          for arg in $( eval echo {2..$#} )
          do
            isIn ${!arg}
          done
        fi

        ;;
      # Si l'extension est 'fsck'
      "fsck" )
        check
        ;;
      # Si l'extension est 'h'
      "h" )
        echo "aide"
        ;;
      # Si l'instruction n'est pas reconnue
      * )
        echo "projet.sh: Cette instruction n'existe pas."
    esac
  else
    echo "projet.sh: il faut un '-' avant une instruction"
  fi
# S'il n'y a pas d'arguments
else
  echo "Il manque des instructions, utilisez -h pour avoir de l'aide."
fi
