#!/bin/bash


function download () {



#Download dos arquivos
wget --read-timeout=20 -P /home/beatriz.rodrigues/Documents "https://www.portaltransparencia.gov.br/download-de-dados/pep/202201"


#Extrair
unzip /home/beatriz.rodrigues/Documents/202201 -d /home/beatriz.rodrigues/Documents/


#Remover arquivos e zip
rm /home/beatriz.rodrigues/Documents/202201
}

function tabelas () {
#Criando tabelas
PGPASSWORD=aml psql -U aml -d aml --c "drop table if exists public.tmp_pep; create table public.tmp_pep( "CPF" varchar(1024) null, "NOME_PEP" varchar(1024) null, "SIGLA_FUNCAO" varchar(1024) null, "DESCRICAO_FUNCAO" varchar(1024) null, "NIVEL_FUNCAO" varchar(1024) null, "NOME_ORGAO" varchar(1024) null, "DATA_INICIO_EXERCICIO" varchar(1024) null, "DATA_FIM_EXERCICIO" varchar(1024) null, "DATA_FIM_CARENCIA" varchar(1024) null);
drop table if exists public.final_pep; create table public.final_pep( "CPF" varchar(1024) null, "NOME_PEP" varchar(1024) null, "SIGLA_FUNCAO" varchar(1024) null, "DESCRICAO_FUNCAO" varchar(1024) null, "NIVEL_FUNCAO" varchar(1024) null, "NOME_ORGAO" varchar(1024) null, "DATA_INICIO_EXERCICIO" date null, "DATA_FIM_EXERCICIO" date null, "DATA_FIM_CARENCIA" date null);"

#Copiar dados para a tabela temporaria

PGPASSWORD=aml psql -U aml -d aml -c "\copy tmp_pep from '/home/beatriz.rodrigues/Documents/202201_PEP.csv' csv header delimiter ';' encoding 'latin1'"

}

#Inserir dados da tabela temporaria na tabela final
function tabelafinal () {
psql -U aml -d aml -c "update public."tmp_pep" set "DATA_INICIO_EXERCICIO" = null where "DATA_INICIO_EXERCICIO" = 'Não informada';

update public."tmp_pep" set "DATA_FIM_EXERCICIO" = null where "DATA_FIM_EXERCICIO" = 'Não informada';

update public."tmp_pep" set "DATA_FIM_CARENCIA" = null where "DATA_FIM_CARENCIA" = 'Não informada';
    
insert into public."final_pep"("CPF", "NOME_PEP", "SIGLA_FUNCAO", "DESCRICAO_FUNCAO","NIVEL_FUNCAO", "NOME_ORGAO", "DATA_INICIO_EXERCICIO", "DATA_FIM_EXERCICIO", "DATA_FIM_CARENCIA"
)
select "CPF", "NOME_PEP", "SIGLA_FUNCAO", "DESCRICAO_FUNCAO", "NIVEL_FUNCAO", "NOME_ORGAO", to_date("DATA_INICIO_EXERCICIO", 'DD/MM/YYYY'), to_date("DATA_FIM_EXERCICIO", 'DD/MM/YYYY'), to_date("DATA_FIM_CARENCIA", 'DD/MM/YYYY') from public."tmp_pep";"

}

comandos='download tabelas tabelafinal Sair'

select cmd in $comandos
do
if [ $cmd == 'Sair' ]
then break
elif [[ "$cmd" == "download" ]]; then
download
elif [[ "$cmd" == "tabelas" ]]; then
tabelas
elif [[ "$cmd" == "tabelafinal" ]]; then
tabelafinal
else
echo "Comando não encontrado."
fi
done

