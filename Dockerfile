# 1. Usa a imagem oficial do Node.js na versão 20-alpine como base.
# Alpine é uma imagem leve, ideal para produção.
FROM node:20-alpine AS base

# 2. Define o diretório de trabalho dentro do container como /app.
WORKDIR /app

# 3. Copia TODO o conteúdo do projeto para o diretório de trabalho no container.
# O .dockerignore garantirá que node_modules e outros arquivos desnecessários não sejam copiados.
COPY . .

# 4. (DEBUG) Lista os arquivos no diretório para confirmar que package.json foi copiado.
RUN ls -la

# 5. Instala as dependências do projeto.
RUN npm install

# 6. Constrói a aplicação Next.js para produção.
RUN npm run build

# 7. Expõe a porta 3000, que é a porta padrão do Next.js.
EXPOSE 3000

# 8. Define o comando para iniciar a aplicação quando o container for executado.
CMD ["npm", "start"]
