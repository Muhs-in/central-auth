FROM node:20-alpine

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --production
COPY prisma ./prisma
COPY src ./src

RUN npx prisma generate

EXPOSE 4000
CMD ["node", "src/index.mjs"]
