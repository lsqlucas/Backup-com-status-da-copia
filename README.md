# Backup-com-status-da-copia
Este script percorre alguns diretórios, onde exlui arquivos antigos e copia os novos com base nos parâmetros informados na execução, e exibe o status da copia a cada arquivo copiado.
A ideia central desse roteiro foi monitorar o status de cada copia de backup e registra-los em log para comparar posteriormente com o arquivo do dia anterior
Os caminhos e arquivos no codigo devem ser alterados conforme a necessidade.

A finalidade desse repositorio é documentar um projeto simples realizado por mim em shell script, para sanar um problema simples no linux:

PROBLEMA: Copiar arquivos com o cp mas não conseguir acompanhar o progresso da copia.

SOLUÇÃO: Utilizar um script que a cada copia lista o tamanho do arquivo em um laço de repetição. 

EXTRA: O Script cria um arquivo de log com base no dia da copia, e reune a informação no log com o log do arquivo do dia anterior para que o analista possa fazer uma melhor analise. O log tambem informa hora de inicio e fim de cada backup 

# Introdução
Crie o repositorio que ira armazenar os logs e conceda as permissões necessarias

mkdir /var/log/backup
chmod 777 -R /var/log/backup

# Execução
Nessa simulação os arquivos que serão copiados estão em /srv/backup/ e o destino da copia é /mnt/

Conceda permissão de execução para o script

chmod +x script.sh

Execute o script repassando os parametros que serão usados pelo find para pesquisar e remover/copiar os arquivos respectivamente:
./script remover copiar

Ex.:./script.sh 20220821 20220829
