# Arya Gross - Render Docker Deployment

FROM node:24-slim AS builder

WORKDIR /app

RUN corepack enable
RUN corepack prepare pnpm@10 --activate

# Tüm projeyi kopyala
COPY . .

# Bağımlılıkları kur
RUN pnpm install --no-frozen-lockfile

# Projeyi build et
RUN pnpm run typecheck:libs || true
RUN pnpm --filter @workspace/firat-gida run build
RUN pnpm --filter @workspace/api-server run build


# Production

FROM node:24-slim

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

RUN corepack enable
RUN corepack prepare pnpm@10 --activate

# Gerekli dosyaları builder'dan al
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-workspace.yaml ./
COPY --from=builder /app/pnpm-lock.yaml ./

COPY --from=builder /app/lib ./lib
COPY --from=builder /app/artifacts/api-server ./artifacts/api-server
COPY --from=builder /app/artifacts/firat-gida ./artifacts/firat-gida

# Production bağımlılıklarını kur
RUN pnpm install --no-frozen-lockfile --prod

EXPOSE 5000

CMD ["node", "artifacts/api-server/dist/index.js"]
