#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctrl_c(){
  echo -e "\n\n${redColour}[!]${endColour} Saliendo...\n"
  tput cnorm && exit 1
}

# Ctrl+C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour} Descargar o actualizar archivos necesarios${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour} Buscar por un nombre de maquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour} Buscar por direccion IP${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour} Buscar por la dificultad de una maquina${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour} Buscar el sistema operativo${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour} Buscar por skill${endColour}"
  echo -e "\t${purpleColour}c)${endColour} ${grayColour} Buscar por certificacion${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour} Obtener link de la resolucion de la maquina en youtube${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

function updateFiles(){

  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js 
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Todods los archivos han sido descargados${endColour}"
    tput cnorm
   else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}"
    tput civis
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No se han encontrado actualizaciones, lo tienes todo al dia ;)${endColour}"
      rm bundle_temp.js
    else
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Se han encontrado actualizaciones disponibles${endColour}"
      sleep 1

      rm bundle.js && mv bundle_temp.js bundle.js

      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Los archivos han sido actualizados${endColour}"
    fi

    tput cnorm
  fi
}


function searchMachine(){
  machineName="$1"
  
  
  machineChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d ',' | sed 's/^ *//')"

  if [ "$machineChecker" ]; then

    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las propiedades de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d ',' | sed 's/^ *//'

  else 
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
  fi
}


function searchIP(){
  ipAddres="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAddres\"" -B 3 | grep "name:" | awk 'NF{print $NF}' | tr -d '""' | tr -d ',')"

  if [ "${machineName}" ]; then 

    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}La maquina correspondiente para la IP${endColour} ${blueColour}$ipAddres${endColour} es ${purpleColour}$machineName${endColour}\n"

  else 

    echo -e "\n${redColour}[!] La direccion IP proporcionada no existe${endColour}"
  fi

}

function getYoutubeLink(){
# cat bundle.js | awk "/name: \"Validation\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d ',' | sed 's/^ *//' | grep "youtube" | awk 'NF {print $NF}'
  machineName="$1"

  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '""' | tr -d ',' | sed 's/^ *//' | grep "youtube" | awk 'NF {print $NF}')"

  if [ $youtubeLink ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}El tutorial para esta maquina esta en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}\n"
  else
    echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}"
  fi

}

function getMachinesDifficulty(){
  difficulty="$1"

  results_Check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column)"

  if [ "$results_Check" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Representando las mquinas que poseen un nivel de dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour}:${endColour}\n"

    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name" | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column
  else 
    echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}\n"
  fi
  
}


function getOSMachines(){
  os=$1

  os_Results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column)"

  if [ "$os_Results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Mostrando las maqiunas cuyo sistema operativo es${endColour} ${blueColour}$os${endColour}"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}"
  fi

}


function getOSDifficultyMachines(){
  difficulty="$1"
  os="$2"

  check_Results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column)"

  if [ "$check_Results" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando maquinas de dificultad${endColour} ${blueColour}$difficulty${endColour} ${grayColour}que tengan sistema operativo${endColour} ${purpleColour}$os${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column
  else 
    echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrecto${endColour}\n"
  fi
}

function getSkill(){
  skill="$1"
  
  check_Skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column)"

  if [ "$check_Skill" ]; then
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}A continuacion se representan las maquinas donde se toca la${endColour} ${purpleColour}$skill${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "skills: " -B 6 | grep "sqli" -i -B 6 | grep "name: " | awk 'NF {print $NF}' | tr -d '""' | tr -d ',' | column
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna maquina con la skill indicada${endColour}\n"
  fi
  
}


function getCertification() {
  cert=$1
  
  check_cert="$(cat bundle.js | grep "$cert" -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column)"

  if [ "$check_cert" ]; then 
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}A continuacion se representan las maquinas con certificacion${endColour} ${purpleColour}$cert${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "$cert" -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '""' | tr -d ',' | column
  else
     echo -e "\n${redColour}[!] No se ha encontrado ninguna maquina con la certificacion indicada${endColour}\n"
  fi


}



# Indicadores
declare -i parameter_counter=0

# Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:c:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;; 
    i) ipAddres="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; parameter_counter+=6;;
    s) skill="$OPTARG"; parameter_counter+=7;;
    c) cert="$OPTARG"; parameter_counter+=8;;
    h) helpPanel;; 
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddres
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSDifficultyMachines  $difficulty $os
elif [ $parameter_counter -eq 7 ]; then
  getSkill "$skill"
elif [ $parameter_counter -eq 8 ]; then
  getCertification "$cert"
else
  helpPanel
fi



































