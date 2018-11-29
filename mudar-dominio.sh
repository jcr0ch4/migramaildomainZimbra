#!/bin/bash
#
#  mudar-dominio.sh
#  
#  Copyright 2018 Jose Carlos <jcr0ch4@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.

# Dominio
maildominio1=$2
maildominio2=$3

# Mensagens
aliasdomino="Criando o alias para o dominio $maildominio1     "
apagandoidentidade="Apagando identidade    "
criandonovaconta="Criando a nova conta no dominio $maildominio2     "
confidentidade="Configurando a identidade DEFAULT     "
renomeaconta="Renomeando a conta do domino $maildominio1 para $maildominio2     "

# Todos os usuarios do dominio informado
#usuarios=$(zmprov -l gaa |grep $maildominio1)

# Pega um arquivo como parametro, este arquivo deve ter em seu conteudo os e-mails que devem ser migrados
# Se o parametro 1 não for informado, devemos finalizar a execução do script.
if [ -z $1 ]
then
	echo "Será necessario informar um arquivo contendo um e-mail pelo menos."
else
# Se ele for informado precisamos ver se o arquivo existe, caso contrario o script tambem deve ser finalizado.
	if [ -e $1 ]
	then
		usuarios=$(cat $1)

		for i in $usuarios
		do
			malias=$(zmprov ga $i | grep MailAlias|head -1|awk -F ": " '{print $2}')
			echo "malias -> $malias"
			malias2=$(zmprov ga $i|grep MailAlias|grep "@$maildominio2"|awk -F ": " '{print $2}')
			echo "malias2 -> $malias2"
			# Se malias2 for vazio 
			if [ -z $malias2 ]
			then 
				echo "Conta sem alias $maildominio2"
				aliasnovo=$(echo $malias2|awk -F ": " '{print $2}')
				novo=$(echo $i|sed -e "s/$(echo $maildominio1)/$(echo $maildominio2)/g")
				echo "zmprov ra $i $novo "&& echo "$renomeaconta [OK]" || echo "$renomeaconta [ Falhou ]"
				zmprov ra $i $novo && echo "$renomeaconta [OK]" || echo  "$renomeaconta [ Falhou ]"
				novo1=$(echo $malias|sed -e "s/$(echo $maildominio1)/$(echo $maildominio2)/g")
				echo "zmprov mid $novo DEFAULT zimbraPrefFromAddress $novo1 zimbraPrefReplyToAddress $novo1 zimbraPrefWhenSentToAddresses $novo1 zimbraPrefWhenSentToEnabled TRUE && echo "$confidentidade [ OK ]" || echo "$confidentidade [ Falhou ]""
				zmprov mid $novo DEFAULT zimbraPrefFromAddress $novo1 zimbraPrefReplyToAddress $novo1 zimbraPrefWhenSentToAddresses $novo1 zimbraPrefWhenSentToEnabled TRUE && echo "$confidentidade [ OK ]" || echo "$confidentidade [ Falhou ]"
				# usage:  addAccountAlias(aaa) {name@domain|id} {alias@domain}
				echo "zmprov aaa $novo $malias "&& echo "$aliasdominio [ OK ]" || echo "$aliasdominio [ Falhou ]"
				zmprov aaa $novo $malias && echo "$aliasdominio [ OK ]" || echo "$aliasdominio  [ Falhou ]"
			# Se nao for vazio 
			else	    
				dominio=$(echo $malias|awk -F "@" '{print $2}')
				echo "dominio -> $dominio"
				dominio2=$(echo $malias2|awk -F "@" '{print $2}')
				echo "dominio2 -> $dominio2"
				if [ "$dominio2"=="$maildominio2" ]
				then
					echo "Dominio $maildominio2 encontrado ..."	
					echo "Apagando o Alias $malias2 do $dominio2"		
					echo "zmprov raa $i $rmail"&& echo "$criandonovaconta [ OK ] "||echo "$criandonovaconta [ Falhou ]"
					zmprov raa $i $malias2 && echo "$criandonovaconta [ OK ] "||echo "$criandonovaconta [ Falhou ]"
					identidades=$(zmprov gid $i|grep name |awk '{print $3}'|grep -v DEFAULT)
					if [ -z $identiddades ]
					then
						echo "Identidade Secundaria não encontreda para : $i"
					else
						echo "Identidade encontrada -> $identidades"
						for d in $identidades
						do
							echo "zmprov did $i $d "&& echo "$apagandoidentidade [ OK ] " || echo "$apagandoidentidade [ Falhou ]"
							zmprov did $i $d && echo "$apagandoidentidade [ OK ] " || echo "$apagandoidentidade [ Falhou ]"
						done
	                fi
					aliasnovo=$(echo $malias2)
					novo=$(echo $i|sed -e "s/$(echo $maildominio1)/$(echo $maildominio2)/g")
					echo "zmprov ra $i $novo "&& echo "$renomeaconta [OK]" || echo "$renomeaconta [ Falhou ]"
					zmprov ra $i $novo && echo "$renomeaconta [OK]" || echo "$renomeaconta [ Falhou ]"
					novo1=$(echo $malias|sed -e "s/$(echo $maildominio1)/$(echo $maildominio2)/g")
					#echo $novo1;read a
					echo "zmprov mid $novo DEFAULT zimbraPrefFromAddress $novo1 zimbraPrefReplyToAddress $novo1 zimbraPrefWhenSentToAddresses $novo1 zimbraPrefWhenSentToEnabled TRUE && echo "$confidentidade [ OK ]" || echo "$confidentidade [ Falhou ]""
					zmprov mid $novo DEFAULT zimbraPrefFromAddress $novo1 zimbraPrefReplyToAddress $novo1 zimbraPrefWhenSentToAddresses $novo1 zimbraPrefWhenSentToEnabled TRUE && echo "$(echo $confidentidade) [ OK ]" || echo "$(echo $confidentidade) [ Falhou ]"
					# usage:  addAccountAlias(aaa) {name@domain|id} {alias@domain}
					echo "zmprov aaa $novo $malias "&& echo "$aliasdominio [ OK ]" || echo "$aliasdominio [ Falhou ]"
					zmprov aaa $novo $malias && echo "$aliasdominio [ OK ]" || echo "$aliasdominio [ Falhou ]"
	
				fi
			fi
		done 
	fi
fi
