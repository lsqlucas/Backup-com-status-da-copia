#!/bin/bash

#-----------------------------------------------------------#
#DECLARAÇÃO DE VARIAVEIS

export DIA=`date +%Y%m%d`
export DAY=`date +%d/%m/%Y" - "%H:%M:%S`
prm=$1
pcp=$2
array[1]=$(echo ".")
array[2]=$(echo "..")
array[3]=$(echo "...")
array[4]=$(echo "....")
array[5]=$(echo " ....")

log="/var/log/backup/log_$DIA"
log1="/var/log/backup/log_1_$DIA"

INDICE=0


#-----------------------------------------------------------#
#Acrescentar verificação de erro na copia

#EXECUÇÃO

#Se, não houver parametro na execução do script
if [[ $1 == "" || $2 == "" ]];

#FAÇA
then
	#Exiba a mensagem abaixo
	echo ""
	echo "O script requer 2 parametros para execução."
	echo "O que deseja remover em /mnt e o que deseja copiar de /srv/backup para /mnt respectivamente!!!"
	echo "./script remover copiar"
	echo "Ex.: ./script.sh 821 829"
	echo ""
c	#sair
	exit
#Se houver
else
	#Contador de bytes inicia em 0
        cont=0
        #Para começar a somar os arquivos do backup
        for Z in $( find /srv/backup -name *$pcp* -type f );
        do
                #A variavel X recebe o tamanho do arquivo em Byte
                X=$(ls -l $Z | cut -d " " -f5 )
                #A variavel cont incrementa a cada repetição 
                cont=$(expr $cont + $X)
        done
        #A variavel alt recebe o calculo que converte o tamanho de Byte para KByte
        alt=$(expr $cont / 1024)
        #A variavel resolv recebe o calculo que converte o tamanho de KByte para MByte
        resolv=$(expr $alt / 1024)

    	#montagem do HD
        #mount -t auto UUID="colocar aqui uuid do hd" /mnt/
        #log de INICIO
        echo "Backup iniciado de $T em: " $DAY >> $log
        #mensagem tela
        echo "Backup de $T iniciado em: " $DAY
        #Escreve no log 1 o que sera removido
        find /mnt/ -name *$prm* -type f >> $log1
        #Remove o resultado do find 
        find /mnt/ -name *$prm* -type f -exec rm -rfv {} \;

	    #A variavel tam recebe o filtro com a informação onde o hd esta montado
        tam=$( df -m | grep /mnt )
        #A variavel tam2 recebe o trecho onde esta o Espaço Livre em MByte
        tam2=$(echo $tam | cut -d " " -f4 )
        #Tamanho estatico pra teste
        #tam2=300000
        S=$(bc <<< "scale=2;$tam2/1024")
        T=$(bc <<< "scale=2;$resolv/1024")


	#se tamanho livre for menor que tamanho do backup
        if [ $tam2 -lt $resolv ]; then
                echo "/mnt não possui espaço suficiente para realizar esse backup"
                R=$(expr $resolv - $tam2)
                echo "TAMANHO LIVRE EM MNT: " $S "GB"
                echo "TAMANHO BACKUP: " $T "GB"
                echo "Para prosseguir libere $R MB"
		exit
        #senão
        else
		#Acessa o diretorio com os arquivos backup
		cd /srv/backup/
		#Escreve no log 1 o que sera copiado
		find . -name *$pcp* -type f -exec ls -lh {} \; >> $log1
		#Inicia laço de repetição, onde para cada resultado fara o que esta dentro do laço. Para A onde $(resultado da pesquisa)
		for A in $( find . -name *$pcp* -type f ); 
		#FAÇA
        	do
			#Escreve a informação em $A no log
                	ls -lh $A >> $log
			#Atribui a variavel F o nome do servidor que esta sendo feito o backup
			F=$(echo $A | cut -d "/" -f2)
			#Mensagem tela
			echo "Copiando" $F "..."
			#Escreve no log o que esta sendo copiado
                	echo "Backup Atual: " >> $log
			#Exporta a data e hora atual para a variavel DAY
                	export DAY=`date +%d/%m/%Y" - "%H:%M:%S`
			#Escreve no log a hora que inicia o backup
                	echo "###### " $A " - INICIADO EM: " $DAY >> $log 
                	#Copia o arquivo para o HD
			cp --parents $A /mnt/ &
			#Variavel G recebe o valor em bytes do tamanho do arquivo
			G=$(ls -l $A | cut -d " " -f5 )
			#Variavel H recebe valor 0 para posterior valor do arquivo copiado
			H=0
			#Recebe o nome do arquivo a ser copiado
			K=$(echo $A | cut -d "/" -f3)
			#echo "/mnt/$F/$K"
			#Incluir verificação se o backup não for feito
			#Inicia laço de repetição para  comparar tamanho atual do arquivo com o arquivo original
			while [ $H -lt $G ];
			do
                                #Tempo de espera
                                sleep 0.2
				#Inicia o indice com 1 (vai ate 4)
				INDICE=$(bc <<< "$INDICE+1")
				#Atribui a variavel G o valor em giga que sera visualizado pelo usuario
				G=$(ls -lh $A | cut -d " " -f5 )
				#Atribui a variavel H o valor em giga que sera visualizado pelo usuario
				H=$( ls -lh /mnt/$F/$K | cut -d " " -f5 )
				#Exibe na tela
				echo -ne "Copiando  $H  de  $G ${array[$INDICE]} \r"
				#Recebe novamente o atributo com o tamanho do arquivo em bytes
				G=$(ls -l $A | cut -d " " -f5 )
                        	#Recebe novamente o atributo com o tamanho do arquivo em bytes
				H=$( ls -l /mnt/$F/$K | cut -d " " -f5 )
				#Quando o indice chegar a 5 zera para começar novamente
				if [ $INDICE = 5 ]; then
				#Zera o indice
				INDICE=0
				#fim se
				fi
			done
			echo -ne '\n'
			#Acrescentar verificação para erro na copia
			#if [ $? -eq 0  ]; then else fi
                	#Exporta a data e hora atual para a variavel DAY
			export DAY=`date +%d/%m/%Y" - "%H:%M:%S`
                	#Escreve no log a hora que termina o backup
			echo "###### " $A " - ENCERRADO EM: "$DAY >> $log
                	#Escreve no log
			echo "Backup Anterior: " >> $log 
                	#Coloca na variavel $D a informação da data anterior
			D=$(date --date "1 day ago" +%Y%m%d)
                	#pesquisa dentro do log do dia anterior pelas linhas relacionadas ao backup atual para posterior comparação
                	grep -m3 $( echo $A | cut -d "/" -f2 ) /var/log/backup/log_$D >> $log 2>/dev/null
			#linha de separação
                	echo "-----------------------------------------------------------------------------------------" >> $log
        	#FEITO
		done;

	#Escreve no log
	echo "#####################################################" >> $log
	#Escreve no LOG o fim do processo
	echo "Processo de backup encerrado em: " $DAY >> $log
	#mensagem tela
        echo "Backup encerrado em: " $DAY
	#Desmonta HD
	#umount /mnt
	fi
fi
#----------------------------------------------------------#
############################################################
#Execute o script repassando os parametros que serão usados#
#pelo find para pesquisar e remover/copiar os arquivos     #
#respectivamente:                                          #
#./script remover copiar                                   #
#                                                          #
#Ex.:./script.sh 821 829                                   #
#                                                          #
#Autor:Lucas Queiroz                                       #
############################################################
