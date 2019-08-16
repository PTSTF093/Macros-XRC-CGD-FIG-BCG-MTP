#!/bin/bash
#
#
#
#
#		Macro monitorização XRC BC01 da BCG
#
#
#
#
#
me=$$
function prelimpeza() 
{
	#ps -ef | grep 'zenity' | awk '{print $2}' | xargs kill
	ps -ef | grep 'title BCG' | awk '{print $2}' | xargs kill
	ps -ef | grep 'BCG_XRC_macro.sh' | awk -v me=$me '$2 != me {print $2}' | xargs kill
}

function matanca() 
{
	#ps -ef | grep 'zenity' | awk '{print $2}' | xargs kill
	ps -ef | grep 'title BCG' | awk '{print $2}' | xargs kill
	#ps -ef | grep 'BCG_XRC_macro.sh' | awk '{print $2}' | xargs kill
	for pid in $(ps -ef | awk '/BCG_XRC_macro.sh/ {print $2}'); do kill -9 $pid; done

}

#limpar outros processos duplicados.
prelimpeza
/usr/bin/x3270 -script -scriptport 7000 -model 2 -title BCG -proxy socks5:socks.lsb.esni.ibm.com:1080 192.168.199.22:23 &

pid=$!
trap "kill $pid" EXIT
trap matanca 1 2 3 6

stringa=( "SUSPENDED" "NO DUMP DATA SETS" "ACCIONAR O SUPORTE TECNICO" "ERRO GRAVE" "Suporte Tecnico" "SUPORTE TECNICO" )

#FUNÇÕES
#FUNÇÕES
function X
{
	x3270if -t 7000 "$1"
	sleep 1
}

function STRING
{
	echo "[$1]"
	#string="$1"
	x3270if -t 7000 "string $1"
	sleep 1
}

function ENTER
{
	x3270if -t 7000 "enter"
	sleep 1
}

function BEEP
{
	for i in {1..3}
	do
		#printf '\7'
		paplay beep-30.wav
		sleep 0.5
	done
}

function GETSTR
{
	x=$1
	y=$2
	len=$3
	#echo "GETSTR x $1 y $2 len $3"
	resultado=$(X "ascii($x,$y,$len)")
	echo $resultado
}

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 1; done
  return 0
}

#
#
########   procurar no ecrã se contém a string
function PRINTSCREEN () 
{
	#ecra=$(X "ascii(0,0,23,80)")
	ecra=$(X "ascii")
	#return $ecra
	echo "$ecra"
}
#
#
########   procurar no ecrã se contém a string
function FIND () 
{
	PRINTSCREEN
	#echo $screen
	#read

	if echo "$ecra" | grep -q "$1"; then
	  #echo "matched";
	  return 1
	else
	  #echo "no match";
	  return 0
	fi
}

#FUNÇÕES
#FUNÇÕES

# Let s3270 get running and bind to the port.
sleep 1

#echo "depois de sleep 1, vou enviar ascii"
# Send it a command.
#x3270if -t 7000 "Ascii"

#recolher user
ENTRY=`zenity --password --username`

case $? in
         0)
#	 	echo "User Name: `echo $ENTRY | cut -d'|' -f1`"
#	 	echo "Password : `echo $ENTRY | cut -d'|' -f2`"
		;;
         1)
                echo "Stop login.";;
        -1)
                echo "An unexpected error has occurred.";;
esac

user=`echo $ENTRY | cut -d'|' -f1`
password=`echo $ENTRY | cut -d'|' -f2`

#exit
#user="post093"
#password="hal#3ibm"
#enviar G MGOPER5 enter
#string
STRING "G"
ENTER
STRING "$user"
ENTER
STRING "$password"
ENTER

#verificar se password correta
FIND "SECURITY"
RC=$?
if [ $RC == 1 ]; then
	BEEP
	zenity --info --text="PASSWORD INVÁLIDA!!!"
	exit
fi
#user correto?
FIND "INVALID"
RC=$?
if [ $RC == 1 ]; then
	BEEP
	zenity --info --text="USER INVÁLIDO!!!"
	exit
fi
#ALREADY logged
FIND "ALREADY"
RC=$?
if [ $RC == 1 ]; then
	BEEP
	zenity --info --text="ALREADY LOGGED ON!!!"
	exit
fi

#aparece ***
ENTER
ENTER
ENTER
#sdf
STRING "sdf"
ENTER

#LOOP PRINCIPAL
for (( ; ; ))
do
	ENTER
	#hora atual
	now_M1=$(date --date='+2 minutes' +"%s")
	now_m1=$(date --date='-2 minutes' +"%s")
	now=$(date +"%R")

	
	#hora do emulador
	#hora_emulador=$(X "ascii(21,74,5)")
	hora_emulador=$(GETSTR 21 74 5)
	hm=$(date --date="$hora_emulador" +"%s")
	
	echo "nou+1 $now_M1 now-1 $now_m1 now $now emulador $hora_emulador hm $hm"

	#
	clear
	echo "REFRESH FEITO $now"
	#fazer coisas
	#fazer coisas
	#fazer coisas
	#fazer coisas
	#
	#
	#
	# beep:		printf '\7'
	# voz:		spd-say "qualquer coisa"
	#	ex: spd-say -i +100 -p 0 -t female1 -r -50 -l pt-pt 'croc'
	# popup:	zenity --info --text "$(date);$(pwd)"
	#
	#
	#
	
	# testar se hora do emulador é a mesma da hora atual com margem de um minuto
	if [[ "$hm" -lt "$now_m1" ]] || [[ "$hm" -gt "$now_M1" ]]; then
		echo "$hora_emulador diferente de $now"
		BEEP
		zenity --info --text "BCG - Hora do emulador não está a atualizar $now != $hora_emulador" &
		#exit 8
	fi
	
	# fazer find no ecrã a procura das strings em stringa[]
	#echo "listar o array"
	#for erros in "${stringa[@]}"; do
		#echo "$erros"
	#done
	#echo "listado"
	
	for erros in "${stringa[@]}"; do
		#echo "fazer o FIND de str: $erros"
		FIND "$erros"
		RC=$?
		#echo "FIND retornou $RC"
		if [ $RC == 1 ]; then
			BEEP
			#spd-say -t female3 -r -100 -l pt-pt "xrc do BCG com mensagem de $erros"
			echo "$now BCG VERIFIQUE: $erros" >> XRC_LOG.txt
			zenity --info --text="$now BCG VERIFIQUE: $erros"
			zenity --question --text="$now DESEJA AGUARDAR 10MIN SEM ALERTAS?"
			if [ $? == 0 ]; then
				echo "MACRO ENTROU EM MODO LOOP 10MIN, SERÁ RETOMADO DEPOIS COM MENSAGEM POPUP"
				for value in {1..10} #20 iterações vezes 30 segundos de sleep = 10 minutos
				do
					ENTER
					sleep 30
					ENTER
					sleep 30
				done
				BEEP
				zenity --info --text "MACRO SERÁ RETOMADA AGORA"
			fi
		fi
	done
	sleep 30
done


echo fim
exit 0
#sleep 30
