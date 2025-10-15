FROM node:20-alpine

# Enable pnpm (comes with Node 20)
RUN corepack enable

WORKDIR /usr/src/app

# Copy lockfiles
COPY package.json pnpm-lock.yaml* ./

# Install ALL dependencies (including dev) to allow prisma generation
RUN pnpm install --frozen-lockfile

# Copy app code
COPY prisma ./prisma
COPY src ./src

# Generate Prisma client
RUN pnpm prisma generate

# Remove dev dependencies to slim image
RUN pnpm prune --prod

EXPOSE 4000

CMD ["node", "src/index.mjs"]
