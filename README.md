# ARYA GROSS — Toptan Gıda E-Ticaret Sistemi

Tam bağımsız, Replit'e özel API veya SDK kullanmayan, kendi sunucunuzda çalışabilen tam yığın Türkçe e-ticaret + admin paneli.

---

## Özellikler

- **Admin Paneli** — ürün, sipariş, stok, kampanya, müşteri, kargo, ödeme yönetimi
- **Müşteri Mağazası** — `/magaza` altında çalışan tam e-ticaret storefront
- **Arya AI Asistanı** — OpenAI destekli Türkçe asistan (opsiyonel)
- **Arya Otomasyon** — tek tıkla ürün tarama, otomatik öneri, onay sistemi
  - Yeni ürün önerileri DB'ye kaydedilir, onaysız hiçbir şey yayınlanmaz
  - 4 platform tedarik linki (Trendyol, Hepsiburada, N11, Cimri)
  - Kampanya adayı tespiti + indirim önerisi
  - Reklam metni üretimi (TikTok, Instagram, Google, WhatsApp)
- **Ödeme Onay Merkezi** — banka transferi + WhatsApp sipariş akışı
- **Finansal Raporlar** — kâr, ciro, muhasebe özeti

---

## Hızlı Başlangıç

```bash
# Gereksinimler: Node.js 24+, PostgreSQL 15+, pnpm

git clone <repo-url> arya-gross
cd arya-gross
cp .env.example .env
# .env dosyasını düzenle

pnpm install
pnpm --filter @workspace/db run push-force
pnpm --filter @workspace/firat-gida run build
pnpm --filter @workspace/api-server run dev
```

Tarayıcı: `http://localhost:5000`

---

## Geliştirme Ortamı

```bash
# API sunucusu (port 5000)
pnpm --filter @workspace/api-server run dev

# Frontend (Vite, farklı terminalde)
pnpm --filter @workspace/firat-gida run dev

# TypeScript kontrolü
pnpm run typecheck

# DB schema güncellemesi
pnpm --filter @workspace/db run push

# API hook kodüretimi (OpenAPI spec değişince)
pnpm --filter @workspace/api-spec run codegen
```

---

## Monorepo Yapısı

```
arya-gross/
├── artifacts/
│   ├── api-server/        # Express 5 REST API (port 5000)
│   └── firat-gida/        # React + Vite admin paneli + mağaza
├── lib/
│   ├── db/                # Drizzle ORM şemaları
│   ├── api-spec/          # OpenAPI spec + Orval codegen
│   ├── api-zod/           # Üretilen Zod şemaları
│   └── api-client-react/  # Üretilen React Query hook'ları
└── scripts/               # Yardımcı scriptler
```

---

## Veritabanı Şeması

| Tablo | Açıklama |
|---|---|
| `products` | Ürünler (V5 — tedarikçi, puan, durum alanları dahil) |
| `categories` | Kategoriler |
| `orders` | Siparişler (JSONB items) |
| `ads` | Reklam metinleri |
| `pending_product_suggestions` | Otomasyon önerileri (onay bekleyenler) |
| `automation_runs` | Otomasyon çalışma geçmişi |
| `campaigns` | Kampanya yönetimi |
| `settings` | Anahtar-değer sistem ayarları |

---

## Ortam Değişkenleri

| Değişken | Zorunlu | Açıklama |
|---|---|---|
| `DATABASE_URL` | ✅ | `postgresql://user:pass@host:5432/db` |
| `SESSION_SECRET` | ✅ | Session şifreleme (rastgele 32 byte) |
| `OPENAI_API_KEY` | ❌ | Arya AI sohbet (olmadan da çalışır) |
| `NODE_ENV` | ✅ | `production` veya `development` |
| `PORT` | ❌ | API port (varsayılan: 5000) |

---

## Deployment

Detaylı kurulum kılavuzu için: **[DEPLOYMENT.md](./DEPLOYMENT.md)**

Desteklenen platformlar:
- Docker Compose (lokal veya VPS)
- [Render.com](https://render.com) (ücretsiz tier mevcut)
- [Railway.app](https://railway.app)
- Kendi Ubuntu/Debian VPS (PM2 + Nginx)
- Herhangi bir Node.js + PostgreSQL ortamı

---

## Replit'ten Bağımsızlık

Bu proje hiçbir Replit'e özgü API, SDK veya servis kullanmaz.  
Replit aboneliği sona erse bile kaynak kodu alınıp herhangi bir platforma taşınabilir.

```bash
# Kodu indir / kopyala
git clone <repo-url>

# Herhangi bir Node.js 24+ ortamında çalıştır
pnpm install && pnpm --filter @workspace/db run push-force && pnpm --filter @workspace/api-server run dev
```

---

## Teknoloji Yığını

| Katman | Teknoloji |
|---|---|
| Runtime | Node.js 24, TypeScript 5.9 |
| API | Express 5 |
| Veritabanı | PostgreSQL 15+ + Drizzle ORM |
| Doğrulama | Zod v4, drizzle-zod |
| Frontend | React 19 + Vite + TailwindCSS + shadcn/ui |
| State | TanStack Query v5 |
| Router | wouter |
| Build | esbuild (API), Vite (Frontend) |
| Paket Yöneticisi | pnpm workspaces |
