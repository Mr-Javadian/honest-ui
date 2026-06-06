<div align="center">
  <img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/frontend/src/assets/logo.png" alt="Honest-UI" width="90" height="90" style="border-radius: 18px">

  <h1 align="center">Honest-UI</h1>

  <p align="center">
    <strong>پنل مدیریت مدرن، متن‌باز و زیبا برای Hysteria 2</strong>
    <br>
    سبک · سریع · غنی از امکانات · زیبا
  </p>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/Mr-Javadian/honest-ui?style=flat-square&logo=opensourceinitiative&logoColor=fff&color=6366f1" alt="License"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/releases"><img src="https://img.shields.io/github/v/release/Mr-Javadian/honest-ui?style=flat-square&logo=github&logoColor=fff&color=6366f1" alt="Release"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/stargazers"><img src="https://img.shields.io/github/stars/Mr-Javadian/honest-ui?style=flat-square&logo=github&logoColor=fff&color=6366f1" alt="Stars"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/Mr-Javadian/honest-ui/release.yml?style=flat-square&logo=githubactions&logoColor=fff&color=6366f1" alt="Build"></a>
    <a href="https://go.dev/blog"><img src="https://img.shields.io/github/go-mod/go-version/Mr-Javadian/honest-ui?style=flat-square&logo=go&logoColor=fff&color=6366f1" alt="Go"></a>
  </p>

  <p>
    <a href="./README.md">English</a>
    <span> · </span>
    <a href="./README_zh-CN.md">简体中文</a>
    <span> · </span>
    <a href="./README_RU.md">Русский</a>
    <span> · </span>
    <a href="./README_FA.md">فارسی</a>
  </p>

  <pre style="background:#1a1a2e;color:#a5b4fc;padding:16px;border-radius:12px;font-family:'SF Mono','Fira Code','Consolas',monospace;line-height:1.5;text-align:left;max-width:640px;margin:16px auto;">
╔══════════════════════════════════════════════════╗
║                Honest-UI v0.x                    ║
║        پنل مدیریت Hysteria 2                      ║
╠══════════════════════════════════════════════════╣
║  🔧  نصب با یک کلیک · systemd · Docker            ║
║  📊  نمایش لحظه‌ای CPU · RAM · دیسک · ترافیک     ║
║  👥  مدیریت کاربران · سهمیه · دستگاه‌ها           ║
║  ⚙️  تنظیمات کامل Hysteria 2 · ACL · TLS · ACME  ║
║  🔗  لینک اشتراک · QR کد · Clash                  ║
║  🤖  ربات تلگرام · هشدار ورود                    ║
║  🌐  English · 中文 · Русский · فارسی             ║
╚══════════════════════════════════════════════════╝</pre>
</div>

---

<br>

## ✨ Honest-UI چیست؟

Honest-UI یک پنل مدیریت کامل و مبتنی بر مرورگر برای **Hysteria 2** است — پروکسی مدرن عبور از سانسور که با پروتکل QUIC کار می‌کند. این پنل جایگزین ویرایش دستی کانفیگ و کار با خط فرمان می‌شود و یک رابط گرافیکی polished در اختیار شما قرار می‌دهد.

این پنل هم برای سرورهای شخصی کوچک و هم برای محیط‌های بزرگ با چندین کاربر طراحی شده است. Honest-UI همه چیز را در یک باینری واحد به شما ارائه می‌دهد: مدیریت کاربران، مانیتورینگ ترافیک، مدیریت اشتراک، تنظیمات کامل Hysteria 2، اعلان‌های تلگرام و یک منوی مدیریت کامل خط فرمان — همه در یک داشبورد مدرن و واکنش‌گرا.

---

## 🚀 نصب با یک دستور

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

نصب‌کننده به طور خودکار سیستم‌عامل و معماری شما را تشخیص می‌دهد، شما را در مراحل نصب راهنمایی می‌کند، رمزهای امن تصادفی تولید می‌کند و پنل را به صورت سرویس systemd یا کانتینر Docker نصب می‌کند. پس از نصب، برای منوی مدیریت تایپ کنید: `honest-ui`

---

## 📦 گزینه‌های نصب

<details>
<summary><b>نصب سریع (systemd) — توصیه شده</b></summary>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

نصب‌کننده مراحل زیر را انجام می‌دهد:
1. تشخیص سیستم‌عامل و معماری
2. دریافت پورت پنل (یا تولید تصادفی)
3. انتخاب IP برای رابط وب
4. تولید رمزهای تصادفی (نام کاربری ۱۲ کاراکتری، رمز عبور ۲۰ کاراکتری)
5. ایجاد مسیر context تصادفی (مثلاً `/KvEi6CQpIWPa7WHnEf5`)
6. نصب به صورت سرویس systemd و راه‌اندازی آن
7. نمایش URL دسترسی و رمزهای ورود
</details>

<details>
<summary><b>نصب دستی (systemd)</b></summary>

```bash
mkdir -p /usr/local/honest-ui/
curl -fsSL https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-amd64 \
  -o /usr/local/honest-ui/honest-ui && chmod +x /usr/local/honest-ui/honest-ui
curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/honest-ui.service \
  -o /etc/systemd/system/honest-ui.service
systemctl daemon-reload && systemctl enable honest-ui && systemctl restart honest-ui
```
</details>

<details>
<summary><b>نصب با Docker</b></summary>

```bash
docker pull mr-javadian/honest-ui

docker run -d --cap-add=NET_ADMIN \
  --name honest-ui --restart always \
  --network=host \
  -e TZ=Asia/Tehran \
  -v /honest-ui/bin:/honest-ui/bin \
  -v /honest-ui/data:/honest-ui/data \
  -v /honest-ui/export:/honest-ui/export \
  -v /honest-ui/logs:/honest-ui/logs \
  mr-javadian/honest-ui
```
</details>

---

## 🖥️ منوی مدیریت

```bash
honest-ui
```

| گزینه | عملیات |
|--------|--------|
| `[1]` | نصب پنل (systemd) |
| `[2]` | به‌روزرسانی پنل (systemd) |
| `[3]` | حذف کامل (systemd) |
| `[4]` | نصب پنل (Docker) |
| `[5]` | به‌روزرسانی پنل (Docker) |
| `[6]` | حذف کامل (Docker) |
| `[7]` | بازنشانی رمز عبور مدیریت |
| `[8]` | تغییر پورت وب |
| `[9]` | مشاهده وضعیت و جزئیات |

---

## 🎯 ویژگی‌ها

### 👥 مدیریت کاربران
مدیریت کامل چرخه حیات کاربران با سهمیه ترافیک، ردیابی پهنای باند، نمایش وضعیت آنلاین، محدودیت دستگاه، قطع دستی اتصال، و ایمپورت/اکسپورت گروهی. هر کاربر لینک اشتراک و QR کد مخصوص خود را دارد.

### 📊 نمایش لحظه‌ای
داشبورد زنده با نمایش منابع سیستم — CPU، حافظه، دیسک — به همراه وضعیت Hysteria 2: نسخه، آپتایم، کاربران آنلاین و دستگاه‌های فعال. همه معیارها به صورت لحظه‌ای به‌روز می‌شوند.

### ⚙️ تنظیمات Hysteria 2
ویرایشگر کامل تنظیمات پوشش‌دهنده تمام گزینه‌های Hysteria 2:
- **Listen** — پورت‌ها، binding IP، port hopping
- **TLS** — فایل‌های cert/key، ACME (HTTP-01، TLS-ALPN-01، DNS-01)، Let's Encrypt / ZeroSSL
- **Obfuscation** — پروتکل salamander با رمز عبور دلخواه
- **QUIC** — stream windows، idle timeout، MTU discovery، congestion control (BBR)
- **Bandwidth** — محدودیت بالا/پایین، نادیده گرفتن client hints
- **Protocol** — UDP forwarding، سرعت‌سنج، sniffing، ACL (فایل/درون‌خطی/GeoIP/GeoSite)
- **Outbounds** — SOCKS5، پروکسی HTTP/HTTPS، مستقیم (با device binding، TCP Fast Open)
- **Masquerade** — فایل سرور، reverse proxy، پاسخ متنی
- **ACME DNS** — پشتیبانی از چندین provider
- **تغییر نسخه** — تغییر نسخه Hysteria 2 مستقیماً از رابط کاربری

### 🔗 سیستم اشتراک
لینک اشتراک و QR کد خودکار برای هر کاربر، فرمت سازگار با Clash، به اشتراک‌گذاری URL نود. کاربران می‌توانند مستقیماً در اپلیکیشن‌های خود ایمپورت کنند.

### 🔐 امنیت
رمزهای تصادفی مدیریت در زمان نصب، مخفی‌سازی مسیر context (مثلاً `/KvEi6CQpIWPa7WHnEf5`)، احراز هویت مبتنی بر JWT، هش کردن رمز عبور با SHA-224، محدودیت نرخ ورود، و HTTPS اختیاری برای خود پنل.

### 🤖 یکپارچه‌سازی با تلگرام
دریافت اعلان‌های ورود با timestamp، نام کاربری و آدرس IP. قالب‌های پیام کاملاً قابل تنظیم با استفاده از متغیرهای `[time]`، `[username]` و `[ip]`.

### 🌐 چند زبانه
رابط کاربری کاملاً ترجمه شده به **انگلیسی**، **چینی ساده شده**، **روسی** و **فارسی**. افزودن زبان‌های جدید ساده است — فقط کافیست یک فایل locale اضافه کنید.

### 🎨 رابط کاربری مدرن
داشبورد تمیز و واکنش‌گرا ساخته شده با Vue 3 و Element Plus، با ظاهر glassmorphism، انیمیشن‌های روان، پالت رنگی الهام گرفته از Catppuccin، و سایدبار جمع‌شونده با ناوبری تب‌بندی.

---

## 🖼️ تصاویر

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/login.png" alt="صفحه ورود" width="400"/></td>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/dashboard.png" alt="داشبورد" width="400"/></td>
  </tr>
  <tr>
    <td align="center"><em>صفحه ورود</em></td>
    <td align="center"><em>مانیتور سیستم</em></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/accounts.png" alt="حساب‌ها" width="400"/></td>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/config.png" alt="تنظیمات" width="400"/></td>
  </tr>
  <tr>
    <td align="center"><em>مدیریت کاربران</em></td>
    <td align="center"><em>تنظیمات سیستم</em></td>
  </tr>
</table>

---

## 🏗️ معماری

```
┌─────────────────────────────────────────────────────┐
│                  مرورگر (Vue 3 SPA)                   │
│  Element Plus · ECharts · Pinia · Vue Router         │
└──────────────────┬──────────────────────────────────┘
                   │  HTTP / HTTPS
                   ▼
┌─────────────────────────────────────────────────────┐
│           Gin Web Framework (Go)                     │
│  ┌─────────┐ ┌──────────┐ ┌──────────────────┐      │
│  │ JWT Auth │ │ Rate Lim.│ │ CORS · Sessions   │      │
│  └─────────┘ └──────────┘ └──────────────────┘      │
│  ┌─────────┐ ┌──────────┐ ┌──────────────────┐      │
│  │ Router  │ │Controller│ │   Service Layer    │      │
│  └─────────┘ └──────────┘ └──────────────────┘      │
│  ┌───────────────────────────────────────────────┐   │
│  │  GORM ORM · SQLite · DAO Layer                 │   │
│  └───────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────┘
                   │  gRPC · REST
                   ▼
┌─────────────────────────────────────────────────────┐
│              Hysteria 2 Server                       │
│  QUIC · ACL · TLS/ACME · Obfs · Masquerade           │
└─────────────────────────────────────────────────────┘
```

---

## 🛠️ تکنولوژی‌ها

| لایه | تکنولوژی |
|-------|------------|
| **بک‌اند** | [Go](https://go.dev/) · [Gin](https://gin-gonic.com/) · [GORM](https://gorm.io/) · [SQLite](https://www.sqlite.org/) |
| **فرانت‌اند** | [Vue 3](https://vuejs.org/) · [TypeScript](https://www.typescriptlang.org/) · [Vite](https://vitejs.dev/) · [Pinia](https://pinia.vuejs.org/) |
| **کیت UI** | [Element Plus](https://element-plus.org/) · [SCSS](https://sass-lang.com/) · [ECharts](https://echarts.apache.org/) · [UnoCSS](https://unocss.dev/) |
| **HTTP Client** | [Axios](https://axios-http.com/) · [Vue Router](https://router.vuejs.org/) |
| **i18n** | [vue-i18n](https://vue-i18n.intlify.dev/) |
| **CI/CD** | [GitHub Actions](https://github.com/features/actions) · [Docker](https://www.docker.com/) |

---

## 💻 توسعه

### پیش‌نیازها

- Go (آخرین نسخه پایدار)
- Node.js (آخرین LTS)
- pnpm

### راه‌اندازی

```bash
# کلون کردن مخزن
git clone https://github.com/Mr-Javadian/honest-ui.git
cd honest-ui

# نصب وابستگی‌های فرانت‌اند
cd frontend
pnpm install
pnpm exec vite build --mode production
cd ..

# اجرای بک‌اند (به طور خودکار فرانت‌اند ساخته شده را سرو می‌کند)
go mod tidy
go run main.go
```

### کامپایل از سورس

```bash
# پلتفرم فعلی
go build -o honest-ui -trimpath -ldflags "-s -w" main.go

# مثال‌های کامپایل چندپلتفرمی
GOOS=linux GOARCH=amd64 go build -o honest-ui-linux-amd64 -trimpath -ldflags "-s -w" main.go
GOOS=linux GOARCH=arm64 go build -o honest-ui-linux-arm64 -trimpath -ldflags "-s -w" main.go
GOOS=linux GOARCH=arm GOARM=6 go build -o honest-ui-linux-armv6 -trimpath -ldflags "-s -w" main.go
```

---

## 📁 ساختار پروژه

```
honest-ui/
│
├── frontend/                  # Vue 3 + TypeScript SPA
│   ├── src/
│   │   ├── api/               # کلاینت‌های Axios API
│   │   ├── assets/            # تصاویر، فونت‌ها، منابع ایستا
│   │   ├── components/        # کامپوننت‌های اشتراکی Vue
│   │   ├── lang/              # فایل‌های locale i18n
│   │   ├── layout/            # پوسته اپ (سایدبار، نوبار، TagsView)
│   │   ├── router/            # تعریف مسیرها و گاردها
│   │   ├── store/             # مخازن Pinia
│   │   ├── styles/            # متغیرهای SCSS سراسری
│   │   ├── utils/             # توابع کمکی
│   │   └── views/             # کامپوننت‌های صفحات
│   └── public/                # منابع ایستا (فاوآیکون و...)
│
├── api/                       # ساختارهای درخواست/پاسخ API
├── cmd/                       # دستورات CLI (Cobra)
├── controller/                # هندلرهای درخواست HTTP
├── dao/                       # لایه دسترسی به دیتابیس (GORM)
├── middleware/                # میان‌افزارهای Gin
├── model/                     # مدل‌های داده، ثابت‌ها، DTOها
├── router/                    # ثبت مسیرها
├── service/                   # منطق کسب‌وکار
├── util/                      # ابزارهای Go
│
├── install.sh                 # اسکریپت نصب یک‌کلیکی
├── Dockerfile                 # تعریف ایمیج کانتینر
├── docker-compose.yml         # تنظیمات Docker Compose
├── honest-ui.service          # فایل واحد systemd
├── build.sh                   # اسکریپت کامپایل چندپلتفرمی
└── build.bat                  # اسکریپت کامپایل ویندوز
```

---

## 📋 الزامات سیستم

| مؤلفه | نیازمندی |
|-----------|-------------|
| **سیستم‌عامل** | CentOS 8+، Ubuntu 20+، Debian 11+ یا هر توزیع مدرن لینوکس |
| **معماری** | `x86_64` / `amd64` · `aarch64` / `arm64` · `armv6` / `armv7` · `386` |
| **حافظه** | حداقل ۲۵۶ مگابایت رم |
| **وابستگی‌ها** | `curl` · `systemd` (برای سرویس) · `nftables` (نصب خودکار) |
| **فضای ذخیره‌سازی** | حدود ۱۰۰ مگابایت برای باینری + اطلاعات |

---

## 🌍 متغیرهای محیطی

| متغیر | پیش‌فرض | توضیحات |
|----------|---------|-------------|
| `H_UI_WEB_PORT` | `8081` | پورت وب سرور پنل |
| `H_UI_WEB_CONTEXT` | `/` | مسیر context URL (مثلاً `/myhiddenpath`) |
| `H_UI_CRT_PATH` | — | مسیر گواهی HTTPS پنل |
| `H_UI_KEY_PATH` | — | مسیر کلید خصوصی HTTPS پنل |
| `H_UI_HTTPS` | `0` | فعال‌سازی HTTPS پنل (برای فعال‌سازی `1`) |
| `GIN_MODE` | `release` | حالت Gin فریمورک |
| `TZ` | `Asia/Tehran` | منطقه زمانی سرور |

همه موارد از صفحه تنظیمات در UI یا از طریق متغیرهای محیطی قابل پیکربندی هستند.

---

## 🔌 نمای کلی API

پنل یک API JSON مبتنی بر REST ارائه می‌دهد:

| متد | Endpoint | توضیحات |
|--------|----------|-------------|
| `POST` | `/api/login` | احراز هویت |
| `GET` | `/api/monitor/system` | مصرف منابع سیستم |
| `GET` | `/api/monitor/hysteria2` | وضعیت Hysteria 2 |
| `GET/POST` | `/api/account/*` | CRUD کاربران |
| `GET` | `/api/account/list` | لیست کاربران (صفحه‌بندی) |
| `POST` | `/api/config/update` | به‌روزرسانی تنظیمات پنل |
| `GET` | `/api/config/list` | دریافت تنظیمات پنل |
| `GET` | `/api/log/system` | لاگ‌های سیستم |
| `GET` | `/api/log/hysteria2` | لاگ‌های Hysteria 2 |
| `POST` | `/api/hysteria2/*` | مدیریت کانفیگ و نسخه Hysteria 2 |

تمام endpointهای API (به جز ورود) نیاز به توکن `Bearer` دریافت شده از `/api/login` دارند.

---

## 🤝 مشارکت

مشارکت‌ها در هر اندازه‌ای خوش‌آمد می‌باشند — رفع باگ، ویژگی‌های جدید، ترجمه، بهبود مستندات.

1. یک [issue](https://github.com/Mr-Javadian/honest-ui/issues) برای بحث در مورد تغییر پیشنهادی خود باز کنید
2. مخزن را fork کنید
3. یک branch ویژگی ایجاد کنید
4. یک pull request ارسال کنید

### راهنمای ترجمه

برای افزودن زبان جدید:
1. فایل `frontend/src/lang/package/en.ts` را کپی کنید → `{lang}.ts`
2. تمام مقادیر متنی را ترجمه کنید
3. locale را در `frontend/src/lang/index.ts` ثبت کنید
4. نام زبان را به عناوین صفحات در `frontend/src/router/index.ts` اضافه کنید

---

## 📄 مجوز

[GPL-3.0](LICENSE) — آزاد برای استفاده، تغییر و توزیع. تمام تغییرات باید تحت همان مجوز متن‌باز باقی بمانند.

---

## 🙏 قدردانی

Honest-UI یک fork از [h-ui](https://github.com/jonssonyan/h-ui) توسط jonssonyan است که خود از [3x-ui](https://github.com/MHSanaei/3x-ui) الهام گرفته شده است. ساخته شده بر روی شانه‌های غول‌ها — با تشکر از جوامع متن‌باز پشت Go، Gin، GORM، Vue، Element Plus، Hysteria 2 و هر کتابخانه‌ای که این پروژه را ممکن ساخته است.

---

## 📬 پشتیبانی و انجمن

- **گزارش باگ و درخواست ویژگی** — [GitHub Issues](https://github.com/Mr-Javadian/honest-ui/issues)
- **بحث و کمک** — [GitHub Discussions](https://github.com/Mr-Javadian/honest-ui/discussions)
- **آسیب‌پذیری‌های امنیتی** — لطفاً یک issue خصوصی باز کنید یا مستقیماً با maintainer تماس بگیرید

---

<p align="center">
  <sub>ساخته شده با ❤️ برای جامعه Hysteria 2</sub>
  <br>
  <sub>اگر این پروژه برای شما مفید است، به آن یک ⭐ بدهید</sub>
</p>
