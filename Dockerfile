# Dockerfile Otimizado para Next.js (Padrão da Indústria)

# --- Estágio 1: Instalação de Dependências ---
# Usa a imagem node:20-alpine como base, que é leve e segura.
FROM node:20-alpine AS deps

# Alpine linux requer esta dependência para o Next.js funcionar corretamente.
RUN apk add --no-cache libc6-compat

# Define o diretório de trabalho dentro do container.
WORKDIR /app

# Copia os arquivos de gerenciamento de pacotes para o diretório de trabalho.
COPY package.json package-lock.json* ./

# Instala as dependências. Usamos 'npm install' para ser mais flexível,
# caso o 'package-lock.json' não exista no seu repositório.
RUN npm install


# --- Estágio 2: Build da Aplicação ---
# Começa a partir da mesma imagem base para consistência.
FROM node:20-alpine AS builder
WORKDIR /app

# Copia as dependências já instaladas do estágio anterior.
COPY --from=deps /app/node_modules ./node_modules
# Copia o restante do código-fonte da sua aplicação.
COPY . .

# Executa o script de build do Next.js.
# O modo 'standalone' (no next.config.js) otimiza a saída para esta etapa.
RUN npm run build


# --- Estágio 3: Imagem Final de Produção ---
# A imagem final também é baseada em node:20-alpine.
FROM node:20-alpine AS runner
WORKDIR /app

# Define o ambiente como 'production' para otimizações do Next.js.
ENV NODE_ENV=production

# Cria um usuário e grupo dedicados por segurança, para que a aplicação não rode como 'root'.
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copia apenas os arquivos essenciais do estágio 'builder'.
# Isso resulta numa imagem final muito menor e mais segura.
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Define o usuário que irá rodar o processo do servidor.
USER nextjs

# Expõe a porta que a aplicação irá usar.
EXPOSE 3000

# Define a variável de ambiente da porta.
ENV PORT 3000

# O comando para iniciar o servidor Next.js otimizado.
CMD ["node", "server.js"]
