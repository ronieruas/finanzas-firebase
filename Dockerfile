# Dockerfile de Estágio Único - Mais simples e robusto

# 1. Usa uma imagem base do Node.js com Alpine Linux, que é leve.
FROM node:20-alpine

# 2. Define o diretório de trabalho dentro do container.
WORKDIR /app

# 3. Copia os arquivos de manifesto de pacotes. O wildcard (*) garante que ambos
# package.json e package-lock.json (se existir) sejam copiados.
COPY package*.json ./

# 4. Instala as dependências do projeto.
# Usamos `npm install` que é mais flexível que `npm ci` se o lockfile não existir.
RUN npm install

# 5. Copia todo o restante do código da aplicação para o diretório de trabalho.
# O .dockerignore irá excluir arquivos desnecessários como node_modules.
COPY . .

# 6. Executa o script de build do Next.js para compilar a aplicação para produção.
RUN npm run build

# 7. Expõe a porta 3000, que é a porta padrão do Next.js.
EXPOSE 3000

# 8. Define o comando padrão para iniciar o servidor Next.js em modo de produção.
CMD ["npm", "start"]
