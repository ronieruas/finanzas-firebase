# Dockerfile

# Estágio 1: Instalação de Dependências
# Este estágio é focado em instalar as dependências do Node.js.
# Ele será cacheado e só será executado novamente se o package.json mudar.
FROM node:20-alpine AS deps
WORKDIR /app
# Copia o package.json de forma explícita para garantir que ele seja encontrado.
COPY package.json ./
# Executa npm install para instalar as dependências.
RUN npm install

# Estágio 2: Build da Aplicação
# Este estágio usa as dependências instaladas e o código-fonte para compilar a aplicação.
FROM node:20-alpine AS builder
WORKDIR /app
# Copia as dependências do estágio anterior
COPY --from=deps /app/node_modules ./node_modules
# Copia o restante do código-fonte da aplicação
COPY . .
# Executa o comando de build do Next.js
RUN npm run build

# Estágio 3: Imagem de Produção Final (Runner)
# Esta é a imagem final, otimizada e leve, que será executada em produção.
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Cria um usuário e grupo não-root por segurança
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copia os artefatos de build otimizados do estágio 'builder'
# O output 'standalone' do Next.js contém apenas o necessário para rodar.
COPY --from=builder /app/.next/standalone ./
# Copia os arquivos estáticos (CSS, JS, etc.)
COPY --from=builder /app/.next/static ./.next/static
# Copia os arquivos da pasta 'public' (imagens, fontes, etc.)
COPY --from=builder /app/public ./public

# Define o usuário não-root para executar a aplicação
USER nextjs

# Expõe a porta em que a aplicação vai rodar
EXPOSE 3000

# Define a variável de ambiente da porta para o Next.js
ENV PORT=3000

# Comando para iniciar o servidor Next.js em modo de produção
CMD ["node", "server.js"]
