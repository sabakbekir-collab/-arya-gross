# ── Stage 1: Dependencies ──────────────────────────────────────────
FROM node:24-slim AS deps
WORKDIR /app

RUN npm install -g pnpm@10

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml ./
COPY lib/db/package.json ./lib/db/
COPY lib/api-spec/package.json ./lib/api-spec/
COPY lib/api-zod/package.json ./lib/api-zod/
COPY lib/api-client-react/package.json ./lib/api-client-react/
COPY scripts/package.json ./scripts/
COPY artifacts/api-server/package.json ./artifacts/api-server/
COPY artifacts/firat-gida/package.json ./artifacts/firat-gida/

RUN pnpm install --frozen-lockfile

# ── Stage 2: Build ─────────────────────────────────────────────────
FROM node:24-slim AS builder
WORKDIR /app
RUN npm install -g pnpm@10

COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/lib/db/node_modules ./lib/db/node_modules
COPY --from=deps /app/artifacts/api-server/node_modules ./artifacts/api-server/node_modules
COPY --from=deps /app/artifacts/firat-gida/node_modules ./artifacts/firat-gida/node_modules

COPY . .

RUN pnpm run typecheck:libs 2>/dev/null || true
RUN pnpm --filter @workspace/firat-gida run build
RUN pnpm --filter @workspace/api-server run build

# ── Stage 3: Production ────────────────────────────────────────────
FROM node:24-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=5000

RUN npm install -g pnpm@10

COPY --from=builder /app/artifacts/api-server/dist ./artifacts/api-server/dist
COPY --from=builder /app/artifacts/api-server/package.json ./artifacts/api-server/package.json
COPY --from=builder /app/artifacts/api-server/node_modules ./artifacts/api-server/node_modules

# Serve built frontend as static from API server (optional)
COPY --from=builder /app/artifacts/firat-gida/dist ./artifacts/firat-gida/dist

EXPOSE 5000

CMD ["node", "--enable-source-maps", "artifacts/api-server/dist/index.mjs"]
