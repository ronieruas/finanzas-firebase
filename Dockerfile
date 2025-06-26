# 1. Installer Stage (deps)
# Get dependencies and cache them
FROM node:20-alpine AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat

WORKDIR /app
# Copy package.json and install dependencies
COPY package.json ./
RUN npm install

# 2. Builder Stage
# Build the application
FROM node:20-alpine AS builder
WORKDIR /app
# Copy dependencies from the 'deps' stage
COPY --from=deps /app/node_modules ./node_modules
# Copy the rest of the source code
COPY . .

# Build the Next.js application
# This will leverage the standalone output mode
RUN npm run build

# 3. Runner Stage
# Create the final, small production image
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy the built application from the 'builder' stage
COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Set the new user
USER nextjs

EXPOSE 3000

ENV PORT=3000
# The server is listening on all interfaces, which is required for Docker
ENV HOSTNAME=0.0.0.0

# Start the application
# The standalone output creates a server.js file
CMD ["node", "server.js"]
