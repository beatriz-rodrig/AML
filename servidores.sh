#!/bin/bash


#Download de dados, extrair e remover zip
function download () {
for mes in {01..11}
do


#Download dos arquivos
wget --read-timeout=20 -P /home/beatriz.rodrigues/Documents/BACEN "https://www.portaltransparencia.gov.br/download-de-dados/servidores/2021${mes}_Servidores_BACEN"
wget --read-timeout=20 -P /home/beatriz.rodrigues/Documents/SIAPE "https://www.portaltransparencia.gov.br/download-de-dados/servidores/2021${mes}_Servidores_SIAPE"

#Extrair
unzip /home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Servidores_BACEN -d /home/beatriz.rodrigues/Documents/BACEN/
unzip /home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Servidores_SIAPE -d /home/beatriz.rodrigues/Documents/SIAPE/

#Remover arquivos e zip
rm /home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Servidores_BACEN
rm /home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Servidores_SIAPE
rm /home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Observacoes.csv
rm /home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Remuneracao.csv
rm /home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Afastamentos.csv
rm /home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Observacoes.csv
rm /home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Remuneracao.csv
rm /home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Afastamentos.csv
done
}


function tabelas () {
#Criando tabelas
PGPASSWORD=aml psql -U aml -d aml --c "
CREATE TABLE public."tmp_servidores" (
Id_SERVIDOR_PORTAL varchar(1024) ,
NOME varchar(1024) ,
CPF varchar(1024) ,
MATRICULA varchar(1024) ,
DESCRICAO_CARGO    varchar(1024) ,
CLASSE_CARGO varchar(1024) ,
REFERENCIA_CARGO varchar(1024) ,
PADRAO_CARGO varchar(1024) ,
NIVEL_CARGO    varchar(1024) ,
SIGLA_FUNCAO varchar(1024) ,
NIVEL_FUNCAO varchar(1024) ,
FUNCAO    varchar(1024) ,
CODIGO_ATIVIDADE varchar(1024) ,
ATIVIDADE varchar(1024) ,
OPCAO_PARCIAL varchar(1024) ,
COD_UORG_LOTACAO varchar(1024) ,
UORG_LOTACAO varchar(1024) ,
COD_ORG_LOTACAO varchar(1024) ,
ORG_LOTACAO    varchar(1024) ,
COD_ORGSUP_LOTACAO varchar(1024) ,
ORGSUP_LOTACAO varchar(1024) ,
COD_UORG_EXERCICIO varchar(1024) ,
UORG_EXERCICIO varchar(1024) ,
COD_ORG_EXERCICIO varchar(1024) ,
ORG_EXERCICIO varchar(1024) ,
COD_ORGSUP_EXERCICIO varchar(1024) ,
ORGSUP_EXERCICIO varchar(1024) ,
COD_TIPO_VINCULO varchar(1024) ,
TIPO_VINCULO varchar(1024) ,
SITUACAO_VINCULO varchar(1024) ,
DATA_INICIO_AFASTAMENTO varchar(1024) ,
DATA_TERMINO_AFASTAMENTO varchar(1024) ,
REGIME_JURIDICO    varchar(1024) ,
JORNADA_DE_TRABALHO varchar(1024) ,
DATA_INGRESSO_CARGOFUNCAO varchar(1024) ,
DATA_NOMEACAO_CARGOFUNCAO varchar(1024) ,
DATA_INGRESSO_ORGAO    varchar(1024) ,
DOCUMENTO_INGRESSO_SERVICOPUBLICO varchar(1024) ,
DATA_DIPLOMA_INGRESSO_SERVICOPUBLICO varchar(1024) ,
DIPLOMA_INGRESSO_CARGOFUNCAO varchar(1024) ,
DIPLOMA_INGRESSO_ORGAO varchar(1024) ,
DIPLOMA_INGRESSO_SERVICOPUBLICO    varchar(1024),
UF_EXERCICIO varchar(1024) 
);
CREATE TABLE public."final_servidores" (
Id_SERVIDOR_PORTAL varchar(32) ,
NOME varchar(128) ,
CPF varchar(64) ,
MATRICULA varchar(24) ,
DESCRICAO_CARGO    varchar(128) ,
CLASSE_CARGO varchar(1) ,
REFERENCIA_CARGO varchar(1024) ,
PADRAO_CARGO varchar(4) ,
NIVEL_CARGO    varchar(4) ,
SIGLA_FUNCAO varchar(4) ,
NIVEL_FUNCAO varchar(5),
FUNCAO    varchar(128) ,
CODIGO_ATIVIDADE varchar(5) ,
ATIVIDADE varchar(64) ,
OPCAO_PARCIAL varchar(32) ,
COD_UORG_LOTACAO varchar(64) ,
UORG_LOTACAO varchar(128) ,
COD_ORG_LOTACAO varchar(6) ,
ORG_LOTACAO    varchar(64) ,
COD_ORGSUP_LOTACAO varchar(6) ,
ORGSUP_LOTACAO varchar(64) ,
COD_UORG_EXERCICIO varchar(32) ,
UORG_EXERCICIO varchar(64) ,
COD_ORG_EXERCICIO varchar(6) ,
ORG_EXERCICIO varchar(64) ,
COD_ORGSUP_EXERCICIO varchar(6) ,
ORGSUP_EXERCICIO varchar(64) ,
COD_TIPO_VINCULO varchar(2) ,
TIPO_VINCULO varchar(32) ,
SITUACAO_VINCULO varchar(64) ,
DATA_INICIO_AFASTAMENTO date ,
DATA_TERMINO_AFASTAMENTO date ,
REGIME_JURIDICO    varchar(64) ,
JORNADA_DE_TRABALHO varchar(32) ,
DATA_INGRESSO_CARGOFUNCAO date ,
DATA_NOMEACAO_CARGOFUNCAO date ,
DATA_INGRESSO_ORGAO    date ,
DOCUMENTO_INGRESSO_SERVICOPUBLICO varchar(64) ,
DATA_DIPLOMA_INGRESSO_SERVICOPUBLICO date ,
DIPLOMA_INGRESSO_CARGOFUNCAO varchar(64) ,
DIPLOMA_INGRESSO_ORGAO varchar(64) ,
DIPLOMA_INGRESSO_SERVICOPUBLICO    varchar(32),
UF_EXERCICIO varchar(2) 
);"


#Copiar dados para a tabela temporaria
for mes in {01..11}
do

PGPASSWORD=aml psql -U aml -d aml --c "\copy tmp_servidores from '/home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Cadastro.csv' csv header delimiter ';' encoding 'latin1'"

PGPASSWORD=aml psql -U aml -d aml --c "\copy tmp_servidores from '/home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Cadastro.csv' csv header delimiter ';' encoding 'latin1'"


done
}

#Inserir dados da tabela temporaria na tabela final
function tabelafinal () {
psql -U aml -d aml -c "insert into public."final_servidores" 
select 
id_servidor_portal ,
nome ,
cpf ,
matricula ,
descricao_cargo    ,
classe_cargo ,
referencia_cargo ,
padrao_cargo ,
nivel_cargo    ,
sigla_funcao ,
nivel_funcao ,
funcao    ,
codigo_atividade ,
atividade  ,
opcao_parcial ,
cod_uorg_lotacao ,
uorg_lotacao ,
cod_org_lotacao ,
org_lotacao    ,
cod_orgsup_lotacao ,
orgsup_lotacao ,
cod_uorg_exercicio ,
uorg_exercicio ,
cod_org_exercicio ,
org_exercicio ,
cod_orgsup_exercicio ,
orgsup_exercicio ,
cod_tipo_vinculo ,
tipo_vinculo ,
situacao_vinculo , 
to_date("data_inicio_afastamento", 'dd/mm/yyyy') as "data_inicio_afastamento"  ,
to_date("data_termino_afastamento", 'dd/mm/yyyy') as "data_termino_afastamento"  ,
regime_juridico    ,
jornada_de_trabalho ,
to_date("data_ingresso_cargofuncao", 'dd/mm/yyyy') as "data_ingresso_cargofuncao"  ,
to_date("data_nomeacao_cargofuncao", 'dd/mm/yyyy') as "data_nomeacao_cargofuncao"  ,
to_date("data_ingresso_orgao", 'dd/mm/yyyy') as "data_ingresso_orgao"  ,
documento_ingresso_servicopublico  ,
to_date("data_diploma_ingresso_servicopublico", 'dd/mm/yyyy') as "data_diploma_ingresso_servicopublico" ,
diploma_ingresso_cargofuncao  ,
diploma_ingresso_orgao  ,
diploma_ingresso_servicopublico    ,
uf_exercicio 
from public."tmp_servidores";"
}

#limpar arquivos
function limpar (){
for mes in {01..11}
do
rm /home/beatriz.rodrigues/Documents/BACEN/2021${mes}_Cadastro.csv
rm /home/beatriz.rodrigues/Documents/SIAPE/2021${mes}_Cadastro.csv
done
}

#opções de execução

comandos='download tabelas tabelafinal limpar Sair'

select cmd in $comandos
do
if [ $cmd == 'Sair' ]
then break
elif [[ "$cmd" == "download" ]]; then
download
elif [[ "$cmd" == "limpar" ]]; then
limpar
elif [[ "$cmd" == "tabelas" ]]; then
tabelas
elif [[ "$cmd" == "tabelafinal" ]]; then
tabelafinal
else
echo "Comando não encontrado."
fi
done
fi






