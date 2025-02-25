#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando atualização da API...${NC}"

# Parar o container existente
echo -e "${YELLOW}Parando container portfolio-api...${NC}"
docker stop portfolio-api
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Container parado com sucesso${NC}"
else
    echo -e "${RED}Erro ao parar o container${NC}"
fi

# Remover o container
echo -e "${YELLOW}Removendo container antigo...${NC}"
docker rm portfolio-api
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Container removido com sucesso${NC}"
else
    echo -e "${RED}Erro ao remover o container${NC}"
fi

# Reconstruir a imagem
echo -e "${YELLOW}Reconstruindo imagem Docker...${NC}"
docker build -t portfolio-api:latest .
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Imagem construída com sucesso${NC}"
else
    echo -e "${RED}Erro ao construir a imagem${NC}"
    exit 1
fi

# Iniciar novo container
echo -e "${YELLOW}Iniciando novo container...${NC}"
docker run -d \
    --name portfolio-api \
    --network portfolio-network \
    -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://portfolio-db:5432/portfolio \
  -e SPRING_DATASOURCE_USERNAME=postgres \
  -e SPRING_DATASOURCE_PASSWORD='G0212snake#' \
    portfolio-api:latest

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Container iniciado com sucesso${NC}"
else
    echo -e "${RED}Erro ao iniciar o container${NC}"
    exit 1
fi

# Aguardar alguns segundos para o container iniciar
echo -e "${YELLOW}Aguardando inicialização...${NC}"
sleep 5

# Verificar status do container
echo -e "${YELLOW}Verificando status do container...${NC}"
if docker ps | grep -q portfolio-api; then
    echo -e "${GREEN}Container está rodando${NC}"
    echo -e "${YELLOW}Logs do container:${NC}"
    docker logs --tail 50 portfolio-api
else
    echo -e "${RED}Container não está rodando${NC}"
    echo -e "${YELLOW}Últimos logs:${NC}"
    docker logs --tail 50 portfolio-api
fi
