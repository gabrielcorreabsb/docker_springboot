#!/bin/bash

# Definição de variáveis
BACKUP_DIR="/backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="site_backup_$DATE"
LOG_FILE="/var/log/backup.log"
MAX_BACKUPS=5

# Função para logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Cria diretório de backup se não existir
mkdir -p $BACKUP_DIR

# Inicia o backup
log_message "Iniciando backup..."

# Cria diretório temporário para o backup
TEMP_DIR="$BACKUP_DIR/$BACKUP_NAME"
mkdir -p $TEMP_DIR

# Backup do /var/www
log_message "Copiando /var/www..."
cp -r /var/www $TEMP_DIR/www

# Backup do /etc/nginx
log_message "Copiando /etc/nginx..."
cp -r /etc/nginx $TEMP_DIR/nginx

# Comprime o backup
log_message "Comprimindo arquivos..."
cd $BACKUP_DIR
tar -czf $BACKUP_NAME.tar.gz $BACKUP_NAME/
rm -rf $TEMP_DIR

# Remove backups antigos
log_message "Removendo backups antigos..."
ls -t $BACKUP_DIR/site_backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)) | while read file; do
    log_message "Removendo backup antigo: $file"
    rm "$file"
done

# Calcula o tamanho do backup
BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME.tar.gz" | cut -f1)

# Registra informações do backup
log_message "Backup concluído com sucesso!"
log_message "Local: $BACKUP_DIR/$BACKUP_NAME.tar.gz"
log_message "Tamanho: $BACKUP_SIZE"

# Verifica o backup
if [ -f "$BACKUP_DIR/$BACKUP_NAME.tar.gz" ]; then
    log_message "Verificação do backup: OK"
else
    log_message "ERRO: Backup não foi criado corretamente!"
fi
