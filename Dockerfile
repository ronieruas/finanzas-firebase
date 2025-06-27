# Dockerfile

# 1. Estágio de Instalação de Dependências (deps)
# Instala as dependências em um estágio separado para otimizar o cache do Docker.
# Esta etapa só será executada novamente se o package.json ou o lockfile for alterado.
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copia os arquivos de gerenciamento de pacotes para o diretório de trabalho.
COPY package.json ./
COPY package-lock.json ./

# Instala as dependências. Usamos 'npm ci' que é mais rápido e seguro para builds.
RUN npm ci


# 2. Estágio de Build (builder)
# Constrói a aplicação Next.js.
FROM node:20-alpine AS builder
WORKDIR /app

# Copia as dependências instaladas do estágio 'deps'.
COPY --from=deps /app/node_modules ./node_modules
# Copia todo o código da aplicação.
COPY . .

# Desativa a telemetria do Next.js (opcional, mas bom para builds).
ENV NEXT_TELEMETRY_DISABLED 1

# Executa o script de build para produção.
RUN npm run build


# 3. Estágio de Produção (runner)
# Cria a imagem final, mínima e otimizada para rodar a aplicação.
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Cria um grupo e um usuário com menos privilégios para rodar a aplicação (boa prática de segurança).
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Copia os arquivos de build do estágio 'builder' otimizados pelo 'output: standalone'.
# Isso inclui apenas o necessário para rodar a aplicação em produção.
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# O Next.js escuta na porta 3000 por padrão.
# A porta do host pode ser mapeada para esta porta no comando 'docker run'.
EXPOSE 3000

# Define a variável de ambiente para a porta.
ENV PORT=3000

# Comando para iniciar o servidor Next.js.
CMD ["node", "server.js"]
