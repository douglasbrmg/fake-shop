#!/bin/bash  

# Função para realizar a verificação da conexão com o banco de dados  
check_database_connection() {  
    # Verifique se a conexão com o banco de dados é bem-sucedida  
    python -c "import psycopg2; psycopg2.connect(dbname=$DB_NAME, user=$DB_USER, password=$DB_PASSWORD, host=$DB_HOST)"  
    return $?  
}  

# Espera o banco de dados estar disponível  
echo "Aguardando o banco de dados ficar disponível..."  
until check_database_connection; do  
    echo "Aguardando o banco de dados..."  
    sleep 2  
done  

# Executa as migrações  
echo "Aplicando migrações do banco de dados..."  
if ! python -m flask db upgrade; then  
    echo "Erro ao aplicar as migrações."  
    exit 1  
fi  

# Inicia o Gunicorn  
echo "Iniciando o Gunicorn..."  
exec python -m gunicorn --bind 0.0.0.0:5000 index:app