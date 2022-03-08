#!/bin/bash

#Download de dados, extrair e remover zip
function downloadcpgf () {
for ano in {17..21}
do
for mes in {01..12}
do

#Download dos arquivos
wget --read-timeout=5 -P /home/beatriz.rodrigues/Downloads "https://
www.portaltransparencia.gov.br/download-de-dados/cpgf/20$ano$mes"

unzip /home/beatriz.rodrigues/Downloads/20$ano$mes -d /home/beatriz.rodrigues/Downloads
rm /home/beatriz.rodrigues/Downloads/20$ano$mes
done
done
}


function tabelas () {
#Criando tabelas
PGPASSWORD=aml psql -U aml -d aml --c "
drop table if exists public."tmp_cpgf";
CREATE TABLE public."tmp_cpgf" (
"codigo_orgao_superior" integer NULL,
"nome_orgao_superior" varchar(1024) NULL,
"codigo_orgao" integer NULL,
"nome_orgao" varchar(1024) NULL,
"codigo_unidade_gestora" integer NULL,
"nome_unidade_gestora" varchar(1024) NULL,
"ano" integer NULL,
"mes" integer NULL,
"cpf_portador" varchar(1024) NULL,
"nome_portador" varchar(1024) NULL,
"documento_favorecido" varchar(1024) NULL,
"nome_favorecido" varchar(1024) NULL,
"transacao" varchar(1024) NULL,
"data" varchar(1024) NULL,
"valor" varchar(1024) NULL
);
drop table if exists public."final_cpgf";
CREATE TABLE public."final_cpgf" (
"codigo_orgao_superior" integer NULL,
"nome_orgao_superior" varchar(1024) NULL,
"codigo_orgao" integer NULL,
"nome_orgao" varchar(1024) NULL,
"codigo_unidade_gestora" integer NULL,
"nome_unidade_gestora" varchar(1024) NULL,
"ano" integer NULL,
"mes" integer NULL,
"cpf_portador" varchar(1024) NULL,
"nome_portador" varchar(1024) NULL,
"documento_favorecido" varchar(1024) NULL,
"nome_favorecido" varchar(1024) NULL,
"transacao" varchar(1024) NULL,
"data" date NULL,
"valor" decimal(20,2) NULL
);"
#COPIA PARA TABELA TEMPORARIAGGG
for ano in {17..21}
do
for mes in {01..12}
do

PGPASSWORD=aml psql -U aml -d aml -c "\copy tmp_cpgf from '/home/beatriz.rodrigues/Downloads/20${ano}${mes}_CPGF.csv' csv header delimiter ';' encoding 'latin1'"

done
done
}
function tabelafinal () {
psql -U aml -d aml -c
"insert into final_cpgf(codigo_orgao_superior, nome_orgao_superior, codigo_orgao, nome_orgao, codigo_unidade_gestora, 
	nome_unidade_gestora, ano, mes, cpf_portador, documento_favorecido, nome_favorecido, transacao, nome_portador, "data", valor)
	select
	codigo_orgao_superior,
	nome_orgao_superior,
	codigo_orgao,
	nome_orgao,
	codigo_unidade_gestora,
	nome_unidade_gestora,
	ano,
	mes,
	cpf_portador,
	documento_favorecido,
	nome_favorecido,
	transacao,
	nome_portador,
	TO_DATE("data", 'DD/MM/YYYY') as "data",
	cast(replace(valor, ',', '.' ) as decimal(20,2)) as valor
	from tmp_cpgf;"
}

cmds='downloadcpgf  tabelas tabelafinal Sair'

select cmd in $cmds
do
if [ $cmd == 'Sair' ]
then break
elif [[ "$cmd" == "downloadcpgf" ]]; then
downloadcpgf
elif [[ "$cmd" == "tabelas" ]]; then
tabelas
elif [[ "$cmd" == "tabelafinal" ]]; then
tabelafinal
else
echo "Comando não encontrado."
fi
done






