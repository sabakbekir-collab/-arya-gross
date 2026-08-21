# Arya Gross — Yayın Kılavuzu

Proje **Vercel (frontend) + Supabase (veritabanı) + Render/Railway (backend)** üzerinde çalışacak şekilde yapılandırılmıştır.

---

## Mimari

```
Kullanıcı
  ↓
Vercel  →  /         (Admin Panel)
        →  /magaza   (Müşteri Mağazası)
        →  /api/*    Render/Railway API Server'a proxy
                         ↓
                    Supabase PostgreSQL
```

---

## 1. Veritabanı — Supabase

1. [supabase.com](https://supabase.com) → New Project oluşturun
2. **Project Settings → Database → Connection string (URI)** kısmını kopyalayın
3. `.env` dosyasına yapıştırın:
   ```
   DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.[REF].supabase.co:5432/postgres
   ```
4. Şemayı uygulayın:
   ```bash
   pnpm --filter @workspace/db run push
   ```

---

## 2. Backend — Render

### Adımlar

1. [render.com](https://render.com) → **New Web Service**
2. GitHub reponuzu bağlayın
3. Ayarlar:

   | Alan | Değer |
   |---|---|
   | **Build Command** | `pnpm install && pnpm run typecheck:libs && pnpm --filter @workspace/api-server run build` |
   | **Start Command** | `node artifacts/api-server/dist/index.js` |
   | **Node Version** | 20+ |

4. **Environment Variables** ekleyin:
   ```
   DATABASE_URL=...
   CORS_ORIGIN=https://arya-gross.vercel.app
   NODE_ENV=production
   ```

### Alternatif — Railway

1. [railway.app](https://railway.app) → New Project → Deploy from GitHub
2. Aynı build/start komutlarını kullanın
3. Railway `PORT` değişkenini otomatik ayarlar

---

## 3. Frontend — Vercel

### Adımlar

1. [vercel.com](https://vercel.com) → **New Project** → GitHub reponuzu bağlayın
2. **Framework Preset**: `Vite`
3. Build ayarları:

   | Alan | Değer |
   |---|---|
   | **Root Directory** | `artifacts/firat-gida` |
   | **Build Command** | `cd ../.. && pnpm install && pnpm run typecheck:libs && cd artifacts/firat-gida && pnpm run build` |
   | **Output Directory** | `dist/public` |

4. **Environment Variables** (Vercel Dashboard → Settings → Environment Variables):
   ```
   VITE_API_URL=https://arya-gross-api.onrender.com
   VITE_WHATSAPP_PHONE=905352765849
   ```

---

## 4. Alan Adı Bağlama

### Frontend (Vercel)
- Vercel Dashboard → Project → **Domains** → Alan adınızı ekleyin
- DNS: CNAME `@ → cname.vercel-dns.com`

### Backend (Render)
- Render Dashboard → Service → **Custom Domains** → `api.arya-gross.com`
- DNS: CNAME `api → [service].onrender.com`

---

## 5. Environment Değişkenleri

### Vercel (Frontend)
| Değişken | Açıklama |
|---|---|
| `VITE_API_URL` | Backend API URL (örn. `https://api.arya-gross.com`) |
| `VITE_WHATSAPP_PHONE` | WhatsApp numarası (örn. `905321234567`) |

### Render/Railway (Backend)
| Değişken | Açıklama |
|---|---|
| `DATABASE_URL` | PostgreSQL/Supabase bağlantı dizisi |
| `CORS_ORIGIN` | İzin verilen frontend URL'leri (virgülle ayırın) |
| `PORT` | Platform otomatik ayarlar, default 3001 |
| `NODE_ENV` | `production` |
| `SESSION_SECRET` | Oturum şifreleme anahtarı |

---

## 6. Build Komutları

```bash
# Bağımlılıkları yükle
pnpm install

# Lib tiplerini derle (gerekli)
pnpm run typecheck:libs

# Frontend build → artifacts/firat-gida/dist/public/
pnpm --filter @workspace/firat-gida run build

# Backend build → artifacts/api-server/dist/index.js
pnpm --filter @workspace/api-server run build

# Veritabanı şemasını uygula
pnpm --filter @workspace/db run push

# API kodunu yeniden oluştur (OpenAPI spec değişince)
pnpm --filter @workspace/api-spec run codegen
```

---

## 7. Yerel Geliştirme

```bash
# .env dosyasını oluştur
cp .env.example .env
# → DATABASE_URL, VITE_WHATSAPP_PHONE vb. doldurun

pnpm install
pnpm run typecheck:libs

# Ayrı terminallerde:
pnpm --filter @workspace/api-server run dev   # localhost:3001
pnpm --filter @workspace/firat-gida run dev   # localhost:5173

# Admin panel:  http://localhost:5173/
# Mağaza:       http://localhost:5173/magaza
# API sağlık:   http://localhost:3001/api/healthz
```

---

## 8. Test Kontrol Listesi

- [ ] `/magaza` açılıyor
- [ ] `/` admin paneli açılıyor
- [ ] Ürün ekleme çalışıyor
- [ ] Sipariş oluşturma çalışıyor (kapıda / havale / WhatsApp)
- [ ] Ödeme Onay Merkezi çalışıyor
- [ ] Excel export/import çalışıyor
- [ ] WhatsApp bağlantıları doğru numaraya gidiyor
- [ ] CORS hatası yok (browser konsolunu kontrol edin)
- [ ] Ürün görselleri bozulmuyor

---

## Notlar

- `VITE_*` değişkenleri **sadece frontend** için geçerlidir (Vite build zamanında gömülür)
- Backend değişkenler (DATABASE_URL, PORT vb.) runtime'da okunur
- Replit üzerinde çalışırken hiçbir şey değiştirmenize gerek yok — platform otomatik yönetir
- `VITE_API_URL` boş bırakılırsa frontend, API isteklerini aynı domain üzerinden `/api` yoluyla yapar (Vercel reverse proxy gerekir)
