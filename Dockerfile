# Dockerfile de Depuração
# Este arquivo é projetado para nos ajudar a entender por que o build está falhando.

# 1. Imagem Base Robusta
# Usamos a imagem `node:20` completa (baseada em Debian) para máxima compatibilidade.
FROM node:20

# 2. Define o diretório de trabalho dentro do container.
WORKDIR /app

# 3. Copia TUDO do diretório atual para dentro do container.
# Esta é a abordagem mais direta para garantir que todos os arquivos sejam incluídos.
COPY . .

# 4. PASSO DE DEPURAÇÃO: Listar arquivos
# Este comando irá mostrar todos os arquivos e permissões no diretório /app.
# Precisamos ver a saída deste comando no log de build.
RUN ls -la

# 5. Instala as dependências.
# Se o passo anterior mostrar o package.json, este deveria funcionar.
RUN npm install

# 6. Constrói a aplicação Next.js para produção.
RUN npm run build

# 7. Define a porta e o comando para iniciar a aplicação.
EXPOSE 3000
CMD ["npm", "start"]
