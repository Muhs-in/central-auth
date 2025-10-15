FROM node:20-alpine

# Enable pnpm via Corepack (comes built into Node 20)
RUN corepack enable

WORKDIR /usr/src/app

# Copy dependency files
COPY package.json pnpm-lock.yaml* ./

# Install only production dependencies
RUN pnpm install --prod --frozen-lockfile

# Copy Prisma and source code
COPY prisma ./prisma
COPY src ./src

# Generate Prisma client
RUN pnpm prisma generate

EXPOSE 4000

CMD ["node", "src/index.mjs"]
