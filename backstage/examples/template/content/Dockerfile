FROM node:22-alpine

WORKDIR /app

COPY --chown=node:node package*.json ./

RUN npm install --omit=dev

COPY --chown=node:node src ./src

USER node

EXPOSE 3000

CMD ["node", "src/index.js"]
