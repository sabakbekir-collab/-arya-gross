# Arya Gross - Render Docker Deployment

FROM node:24-slim AS builder

WORKDIR /app

RUN corepack enable
RUN corepack prepare pnpm@10 --activate

# Tüm projeyi kopyala.
# Böylece olmayan package.json dosyalarına özel COPY hatası oluşmaz.
COPY . .

# Bağımlılıkları kur
RUN pnpm install --no-frozen-lockfile

# Projeyi build et
RUN pnpm run build

# Production
FROM node:24-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

RUN corepack enable
RUN corepack prepare pnpm@10 --activate

# Build edilen proje ve gerekli dosyalar
COPY --from=builder /app /app

EXPOSE 5000

CMD ["sh", "-c", "node artifacts/api-server/dist/index.js"]
