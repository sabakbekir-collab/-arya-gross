# Arya Gross — Türk E-Ticaret Admin Paneli

Arya Gross, tedarikçi kataloğundan otomatik ürün bulan, sipariş yöneten ve müşteriye özel bir storefront sunan tam stack Türkçe e-ticaret platformu.

## Run & Operate

- `pnpm --filter @workspace/api-server run dev` — API sunucusunu çalıştır (port 5000)
- `pnpm --filter @workspace/firat-gida run dev` — React frontend çalıştır
- `pnpm run typecheck` — Tüm paketleri kontrol et
- `pnpm run build` — Typecheck + build
- `pnpm --filter @workspace/api-spec run codegen` — OpenAPI'dan hook ve Zod şema üret
- `pnpm --filter @workspace/db run push-force` — DB şema değişikliklerini zorla uygula (dev only)
- Required env: `DATABASE_URL` — Postgres bağlantı dizisi
- Optional env: `SESSION_SECRET`, `OPENAI_API_KEY`

## Stack

- pnpm workspaces, Node.js 24, TypeScript 5.9
- API: Express 5
- DB: PostgreSQL + Drizzle ORM
- Validation: Zod (`zod/v4`), `drizzle-zod`
- API codegen: Orval (from OpenAPI spec)
- Build: esbuild (CJS bundle)
- Frontend: React 19 + Vite + Tailwind + shadcn/ui

## Where things live

- `lib/db/src/schema/` — Tüm DB şemaları (products, orders, supplier_products, pending_suggestions…)
- `lib/api-spec/openapi.yaml` — OpenAPI kaynak dosyası (source of truth for API contracts)
- `lib/api-zod/src/generated/api.ts` — Üretilen Zod şemaları
- `artifacts/api-server/src/routes/` — Tüm Express route'ları
- `artifacts/firat-gida/src/pages/` — Admin panel + müşteri sitesi sayfaları
- `artifacts/firat-gida/src/pages/store/` — Müşteri storefront sayfaları
- Brand: Red `#DC2626`, Yellow `#FBBF24`

## Architecture decisions

- **Arya Otomasyon** (`arya-automation.ts`): IDEAS listesi kaldırıldı. Yalnızca `supplier_products` tablosundan veri okur. `suggestedSalePrice` varsa onu kullanır, yoksa `supplierPrice × 1.45` hesaplar. En kârlı 20 ürünü `pending_product_suggestions`'a atar.
- **Tedarikçi Kataloğu** (`supplier-import.ts`): CSV/Excel yüklemesiyle `supplier_products` tablosuna kayıt yapar. Aynı isim veya barkod tekrar eklenmez.
- **Sepet**: Sunucu tarafı in-memory Map (session yok). Tüm kullanıcılar aynı sepeti paylaşır — prodüksiyonda session tabanlı cart gerekir.
- **Ödeme durumu**: Kapıda ödeme → `paymentStatus="bekliyor"`, Havale/EFT → `paymentStatus="havale-bekleniyor"`.
- **Ürün filtresi**: Müşteri storefront'u `productStatus==="active"` ürünleri gösterir. Admin panel tüm ürünleri gösterir + aktif/pasif filtresi.

## Product

- **Admin Panel** (`/`): Dashboard, Ürün Yönetimi, Siparişler, Arya Otomasyon, Tedarikçi Yükle, Kampanyalar
- **Müşteri Sitesi** (`/magaza`): Ürün listesi, sepet, checkout (kapıda ödeme / havale / WhatsApp)
- **Arya Otomasyon**: Tedarikçi kataloğunu okur → kâr hesaplar → öneri oluşturur → admin onaylar → sitede yayınlanır
- **Sipariş Akışı**: Müşteri sipariş → orders tablosuna yazar → admin panelde görünür → durum güncellenir → WhatsApp ile takip

## VPS / Render / Railway Kurulumu

```bash
# 1. Bağımlılıkları kur
pnpm install

# 2. Environment variables
DATABASE_URL=postgresql://user:pass@host:5432/dbname
SESSION_SECRET=random_secret_here
OPENAI_API_KEY=sk-...   # opsiyonel

# 3. DB şemasını uygula (ilk kurulumda)
pnpm --filter @workspace/db run push-force

# 4. API server'ı build et
pnpm --filter @workspace/api-server run build

# 5. Frontend'i build et
pnpm --filter @workspace/firat-gida run build

# 6. API server'ı çalıştır
node artifacts/api-server/dist/index.js
# PORT=5000 (veya istediğiniz port)

# 7. Frontend'i serve et (nginx, serve, etc.)
# artifacts/firat-gida/dist/ klasörünü static host olarak sun
# API_BASE_URL environment variable'ını ayarla
```

### Railway / Render konfigürasyonu

```yaml
# render.yaml örneği
services:
  - type: web
    name: arya-gross-api
    env: node
    buildCommand: pnpm install && pnpm --filter @workspace/db run push-force && pnpm --filter @workspace/api-server run build
    startCommand: node artifacts/api-server/dist/index.js
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: arya-db
          property: connectionString
      - key: PORT
        value: 5000
```

## User preferences

- Türkçe UI, Türkçe API mesajları
- Mock data kullanma — tüm veriler gerçek DB'den gelsin
- TypeScript hatası bırakma

## Gotchas

- `pnpm run typecheck:libs` → ardından `push-force` — şema değişikliklerinde her zaman bu sırayı izle
- `await import()` kullanma drizzle operator'leri için — zaten import edilmiş olduğundan
- `router.post("/products/cleanup", ...)` endpoint'i `/products/:id` pattern'den ÖNCE register edilmeli
- Cart in-memory'de — server restart edilince sepet sıfırlanır (bilinen kısıtlama)

## Pointers

- See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details
- API proxy path: `/api/...` → api-server port 5000
- Frontend proxy path: `/` → firat-gida port (PORT env var)
