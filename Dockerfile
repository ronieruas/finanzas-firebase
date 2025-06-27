# Dockerfile

# 1. Estágio de Instalação de Dependências (deps)
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copia os arquivos de gerenciamento de pacotes para o diretório de trabalho.
COPY package.json package-lock.json* ./

# Instala as dependências.
RUN npm ci

# 2. Estágio de Build (builder)
FROM node:20-alpine AS builder
WORKDIR /app

# Copia as dependências instaladas do estágio 'deps'.
COPY --from=deps /app/node_modules ./node_modules
# Copia todo o código da aplicação.
COPY . .

# Desativa a telemetria do Next.js.
ENV NEXT_TELEMETRY_DISABLED=1

# Executa o script de build para produção.
RUN npm run build

# 3. Estágio de Produção (runner)
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Cria um grupo e um usuário com menos privilégios.
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Copia os arquivos de build otimizados.
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Expose port 3000.
EXPOSE 3000

# Define a variável de ambiente para a porta.
ENV PORT=3000

# Comando para iniciar o servidor Next.js.
CMD ["node", "server.js"]