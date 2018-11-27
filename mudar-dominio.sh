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


# Mensagens
aliasdomino="Criando o alias para o dominio wheatonbrasil.com.br     "
apagandoidentidade="Apagando identidade    "
criandonovaconta="Criando a nova conta no dominio wheaton.com.br     "
confidentidade="Configurando a identidade DEFAULT     "
renomeaconta="Renomeando a conta do domino wheatonbrasil.com.br para wheaton.com.br     "
#usuarios=$(zmprov -l gaa |grep wheatonbrasil.com.br)
#usuarios="daniele.ti@wheatonbrasil.com.br theo.ti@wheatonbrasil.com.br"
#larissa.ti@wheatonbrasil.com.br maximiliano.ti@wheatonbrasil.com.br ricardov.ti@wheatonbrasil.com.br eliel.ti@wheatonbrasil.com.br john.ti@wheatonbrasil.com.br rafael.ti@wheatonbrasil.com.br"
#usuarios="eliel.ti@wheatonbrasil.com.br"
#usuarios="rafael.ti@wheatonbrasil.com.br larissa.ti@wheatonbrasil.com.br"
# usuarios="maximiliano.ti@wheatonbrasil.com.br"
#usuarios="ricardov.ti@wheatonbrasil.com.br"
# usuarios="andre.ti@wheatonbrasil.com.br fernandof.vrs@wheatonbrasil.com.br"
usuarios="andre.ti@wheatonbrasil.com.br"

for i in $usuarios
do
    malias=$(zmprov ga $i | grep MailAlias|head -1)
    malias2=$(zmprov ga $i|grep MailAlias|grep "@wheaton.com.br")

    if [ -n $(zmprov ga $i |grep MailAlias |grep "@wheaton.com.br"|awk -F ":" '{print $2}') ]
    then    
	dominio=$(echo $malias|awk -F "@" '{print $2}')
	dominio2=$(echo $malias2|awk -F "@" '{print $2}')
		if [ "$dominio2"=="wheaton.com.br" ]
		then
		
			echo "Apagando o Alias $(echo $malias2|awk -F ":" '{print $2}') do $dominio2"
			# Precisa ser verificado o retorno antes de proceguir.
			rmail=$(echo $malias2|awk -F ": " '{print $2}')
			#echo "zmprov raa $i $rmail"&& echo "$criandonovaconta [ OK ] "||echo "$criandonovaconta [ Falhou ]"
			zmprov raa $i $rmail&& echo "$(echo $criandonovaconta) [ OK ] "||echo "$criandonovaconta [ Falhou ]"

			# Precisa ser verificado se o retorno esta OK ou nao
			identidades=$(zmprov gid $i|grep name |awk '{print $3}'|grep -v DEFAULT)
			echo "Identidade encontrada -> $identidades"
			for d in $identidades
			do
				#echo "zmprov did $i $d "&& echo "$(echo $apagandoidentidade) [ OK ] " || echo "$(echo $apagandoidentidade) [ Falhou ]"
				zmprov did $i $d && echo "$(echo $apagandoidentidade) [ OK ] " || echo "$(echo $apagandoidentidade) [ Falhou ]"

			done

			# Precisa verificar o retorno para as variaveis
			aliasnovo=$(echo $malias|awk -F ": " '{print $2}')
			novo=$(echo $i|sed -e 's/wheatonbrasil/wheaton/g')
	
			#echo "zmprov ra $i $novo "&& echo "$(echo $renomeaconta) [OK]" || echo "$(echo $renomeaconta) [ Falhou ]"
			# VERIFICAR SE A CONTA TEM ALGUM ALIAS
			zmprov ra $i $novo && echo "$(echo $renomeaconta) [OK]" || echo "$(echo $renomeaconta) [ Falhou ]"
			echo "Aguade novamente ... ";read a
			novo1=$(echo $malias|awk -F ": " '{print $2}'|sed -e 's/wheatonbrasil/wheaton/g')
	
			zmprov mid $novo DEFAULT zimbraPrefFromAddress $novo1 zimbraPrefReplyToAddress $novo1 zimbraPrefWhenSentToAddresses $novo1 zimbraPrefWhenSentToEnabled TRUE && echo "$(echo $confidentidade) [ OK ]" || echo "$(echo $confidentidade) [ Falhou ]"

			#echo "zmprov aaa $novo $aliasnovo "&& echo "$aliasdominio [ OK ]" || echo "$aliasdominio [ Falhou ]"
			zmprov aaa $novo $aliasnovo && echo "$(echo $aliasdominio) [ OK ]" || echo "$(echo $aliasdominio) [ Falhou ]"
	
		fi
    fi
done 
