#!/bin/bash
#
#
#
#
#		Macro monitorização XRC MTP
#
#
#
#
#
me=$$
ps -ef | grep 'MTP_XRC_macro.sh' | awk -v me=$me '$2 != me {print $2}' | xargs kill

/usr/bin/x3270 -script -scriptport 5500 -model 2 -title MTP -proxy socks5:socks.lsb.esni.ibm.com:1080 192.168.199.42:23 &

pid=$!
trap "kill $pid" EXIT

	# "ACCIONAR O SUPORTE TECNICO"
	# "SUSPENDED                 "
	# "NO DUMP DATA SETS         "
	# "DUPLEXED                  "
	# "ERRO GRAVE                "
	# "Suporte Tecnico           "
stringa=( "ACCIONAR O SUPORTE TECNICO" "SUSPENDED" "NO DUMP DATA SETS" "DUPLEXED" "ERRO GRAVE" "Suporte Tecnico" )

#FUNÇÕES
#FUNÇÕES
function X
{
	x3270if -t 5500 "$1"
	sleep 1
}

function STRING
{
	echo "[$1]"
	#string="$1"
	x3270if -t 5500 "string $1"
	sleep 1
}

function ENTER
{
	x3270if -t 5500 "enter"
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
#x3270if -t 5500 "Ascii"

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
	
	echo "now+1 $now_M1 now-1 $now_m1 now $now emulador $hora_emulador hm $hm"
	echo "now+1 $now_M1 now-1 $now_m1 now $now emulador $hora_emulador hm $hm"
	echo "now+1 $now_M1 now-1 $now_m1 now $now emulador $hora_emulador hm $hm"

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
		zenity --info --text "MTP - Hora do emulador não está a atualizar $now != $hora_emulador" &
		echo "$now MTP - Hora do emulador não está a atualizar $now != $hora_emulador" >> XRC_LOG.txt
		#exit 8
	fi
	
	###########################
	###########################
	###########################
	###########################
	#	PROD#SUS
	#
	###########################
	###########################
	###########################
	
	#verificar se hora = 0 e se minutos < 6
	HH3270=$(echo $hora_emulador | cut -d':' -f 1)
	MM3270=$(echo $hora_emulador | cut -d':' -f 2)
	if [[ "$HH3270" -eq "00" ]] && [[ "$MM3270" -gt "05" ]] ; then
	#if [[ "$HH3270" -eq "13" ]] && [[ "$MM3270" -gt "59" ]] ; then
		FLAG_PROD_SUS=0
	fi
	
	if [[ "$HH3270" -eq "00" ]] && [[ "$MM3270" -lt "06" ]] ; then
	#if [[ "$HH3270" -eq "13" ]] && [[ "$MM3270" -lt "58" ]] ; then
		if [[ $FLAG_PROD_SUS -eq 0 ]] ; then
			BEEP
			echo "$now HORA PROD#SUS" >> XRC_LOG.txt
			if zenity --question --text="ESTÁ NA HORA DE EXECUTAR O PROD#SUS QUER LANÇAR AUTOMATICAMENTE O COMANDO?"; then
				FLAG_PROD_SUS=1
				#FAZER O PROD"SUS
				#zenity --info --text="You pressed \"Yes\"!"
				STRING "PROD#SUS"
				ENTER
				echo "$now PROD#SUS AUTOMÁTICO ENVIADO" >> XRC_LOG.txt
				sleep 5
				FIND "***"
				if [ $? == 1 ] ; then
					ENTER
					echo "$now PROD#SUS encontrado *** e dado ENTER" >> XRC_LOG.txt
					echo $(PRINTSCREEN) >> XRC_LOG.txt
				else
					zenity --info --text="$now MTP VERIFIQUE: PROD#SUS enviado corretamente? interrompido? continue de onde ficou, esta macro vai esperar 5 minutos para a operação ter tempo de introduzir comandos nesta consola."
					echo "$now PROD#SUS sem ***, entrou em espera 5min" >> XRC_LOG.txt
					echo $(PRINTSCREEN) >> XRC_LOG.txt
					sleep 60*5
					echo "$now PROD#SUS sem ***, saiu da espera 5min" >> XRC_LOG.txt
					echo $(PRINTSCREEN) >> XRC_LOG.txt
				fi
			fi
		fi
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
			echo "$now MTP VERIFIQUE: $erros" >> XRC_LOG.txt
			zenity --info --text="$now MTP VERIFIQUE: $erros"
			zenity --question --text="$now DESEJA AGUARDAR 10MIN SEM ALERTAS?"
			if [ $? == 0 ]; then
				echo "MACRO ENTROU EM MODO LOOP 10MIN, SERÁ RETOMADO DEPOIS COM MENSAGEM POPUP"
				echo "$now MACRO ENTROU EM MODO LOOP 10MIN" >> XRC_LOG.txt
				for value in {1..10} #20 iterações vezes 30 segundos de sleep = 10 minutos
				do
					ENTER
					sleep 30
					ENTER
					sleep 30
				done
				BEEP
				zenity --info --text "MACRO SERÁ RETOMADA AGORA"
				echo "$now MACRO SAIU DE MODO LOOP 10MIN" >> XRC_LOG.txt
			fi
		fi
	done
	sleep 30
done


echo fim
exit 0
#sleep 30
