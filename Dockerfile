# Use Node.js with corepack enabled (for pnpm)
FROM node:20-alpine

# Enable pnpm via corepack
RUN corepack enable

WORKDIR /usr/src/app

# Copy only package files first for caching
COPY package.json pnpm-lock.yaml* ./

# Install dependencies (including dev for prisma)
RUN pnpm install --frozen-lockfile

# Copy rest of code
COPY prisma ./prisma
COPY src ./src

# Generate Prisma client explicitly using npx (ensures binary resolution)
RUN npx prisma generate

# Then remove dev dependencies for smaller image
RUN pnpm prune --prod

EXPOSE 4000
CMD ["node", "src/index.mjs"]
