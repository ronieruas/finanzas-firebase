# Use uma imagem base do Node.js 20 Alpine, que é leve.
FROM node:20-alpine

# Define o diretório de trabalho dentro do contêiner.
WORKDIR /app

# Copia os arquivos de definição de pacote.
COPY package*.json ./

# Instala as dependências do projeto.
RUN npm install

# Copia o restante do código da aplicação.
COPY . .

# Compila a aplicação Next.js para produção.
RUN npm run build

# Expõe a porta em que a aplicação será executada.
EXPOSE 3000

# O comando para iniciar a aplicação.
CMD ["npm", "start"]
