<div align="center">
  <img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/frontend/src/assets/logo.png" alt="Honest-UI" width="90" height="90" style="border-radius: 18px">

  <h1 align="center">Honest-UI</h1>

  <p align="center">
    <strong>A modern, open‑source management panel for Hysteria 2</strong>
    <br>
    Lightweight · Fast · Feature‑rich · Beautiful
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
  </p>

  <pre style="background:#1a1a2e;color:#a5b4fc;padding:16px;border-radius:12px;font-family:'SF Mono','Fira Code','Consolas',monospace;line-height:1.5;text-align:left;max-width:640px;margin:16px auto;">
╔══════════════════════════════════════════════════╗
║                Honest-UI v0.x                    ║
║        Hysteria 2 Management Panel               ║
╠══════════════════════════════════════════════════╣
║  🔧  One‑click install · systemd · Docker        ║
║  📊  Real‑time CPU · RAM · disk · traffic        ║
║  👥  User management · quotas · devices          ║
║  ⚙️  Full Hysteria 2 config · ACL · TLS · ACME   ║
║  🔗  Subscription links · QR codes · Clash       ║
║  🤖  Telegram bot · login alerts                 ║
║  🌐  English · 中文 · Русский                     ║
╚══════════════════════════════════════════════════╝</pre>
</div>

---

<br>

## ✨ What is Honest-UI?

Honest-UI is a complete, browser‑based management panel for **Hysteria 2** — the modern, censorship‑circumvention proxy powered by the QUIC protocol. It replaces manual config editing and command‑line juggling with a polished graphical interface.

Designed for both small personal servers and large multi‑user deployments, Honest-UI gives you everything you need in a single binary: user management, traffic monitoring, subscription handling, full Hysteria 2 configuration, Telegram notifications, and a full CLI management menu — all wrapped in a modern, responsive dashboard.

---

## 🚀 One‑Command Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

The installer detects your OS and architecture, guides you through setup, generates secure random credentials, and installs the panel as a systemd service or Docker container. After installation, type `honest-ui` for the management menu.

---

## 📦 Installation Options

<details>
<summary><b>Quick install (systemd) — recommended</b></summary>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

The installer will:
1. Detect your OS & architecture
2. Prompt for panel port (or auto‑generate)
3. Let you choose the web interface IP
4. Generate random credentials (12‑char username, 20‑char password)
5. Create a random context path (e.g., `/KvEi6CQpIWPa7WHnEf5`)
6. Install as a systemd service and start it
7. Print the access URL and credentials
</details>

<details>
<summary><b>Manual (systemd)</b></summary>

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
<summary><b>Docker</b></summary>

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

## 🖥️ Management Menu

```bash
honest-ui
```

| Option | Action |
|--------|--------|
| `[1]` | Install Panel (systemd) |
| `[2]` | Upgrade Panel (systemd) |
| `[3]` | Uninstall (systemd) |
| `[4]` | Install Panel (Docker) |
| `[5]` | Upgrade Panel (Docker) |
| `[6]` | Uninstall (Docker) |
| `[7]` | Reset admin password |
| `[8]` | Change web port |
| `[9]` | View status & details |

---

## 🎯 Features

### 👥 User Management
Full user lifecycle management with traffic quotas, bandwidth tracking, online status monitoring, device limits, manual kick/force‑offline, and bulk import/export. Each user gets a unique subscription link and QR code.

### 📊 Real‑Time Monitoring
Live dashboard showing system resource usage — CPU, memory, disk — alongside Hysteria 2 status: version, uptime, online users, and active devices. All metrics update in real time.

### ⚙️ Hysteria 2 Configuration
A full config editor covering every Hysteria 2 option:
- **Listen** — ports, IP binding, port hopping
- **TLS** — cert/key files, ACME (HTTP‑01, TLS‑ALPN‑01, DNS‑01), Let's Encrypt / ZeroSSL
- **Obfuscation** — salamander protocol with custom password
- **QUIC** — stream windows, idle timeout, MTU discovery, congestion control (BBR)
- **Bandwidth** — up/down limits, ignore client hints
- **Protocol** — UDP forwarding, speed test server, sniffing, ACL (file/inline/GeoIP/GeoSite)
- **Outbounds** — SOCKS5, HTTP/HTTPS proxy, direct (with device binding, TCP Fast Open)
- **Masquerade** — file server, reverse proxy, string response
- **ACME DNS** — multiple provider support
- **Version switching** — change Hysteria 2 version directly from the UI

### 🔗 Subscription System
Auto‑generated subscription links and QR codes per user, Clash‑compatible format, node URL sharing. Users can import directly into their client apps.

### 🔐 Security
Random admin credentials generated at install time, context‑path obfuscation (e.g. `/KvEi6CQpIWPa7WHnEf5`), JWT‑based authentication, SHA‑224 password hashing, rate limiting on login, and optional HTTPS for the panel itself.

### 🤖 Telegram Integration
Receive login notifications with timestamps, usernames, and IP addresses. Fully customizable message templates using `[time]`, `[username]`, and `[ip]` placeholders.

### 🌐 Multi‑Language
Fully translated interface in **English**, **简体中文**, and **Русский**. Adding new languages is straightforward — just add a locale file.

### 🎨 Modern UI
A clean, responsive dashboard built with Vue 3 and Element Plus, featuring a glassmorphism aesthetic, smooth animated transitions, Catppuccin‑inspired color palette, and a collapsible sidebar with tabbed navigation.

---

## 🖼️ Screenshots

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/login.png" alt="Login" width="400"/></td>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/dashboard.png" alt="Dashboard" width="400"/></td>
  </tr>
  <tr>
    <td align="center"><em>Login Page</em></td>
    <td align="center"><em>System Monitor</em></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/accounts.png" alt="Accounts" width="400"/></td>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/config.png" alt="Config" width="400"/></td>
  </tr>
  <tr>
    <td align="center"><em>User Management</em></td>
    <td align="center"><em>System Configuration</em></td>
  </tr>
</table>

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Browser (Vue 3 SPA)                 │
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

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | [Go](https://go.dev/) · [Gin](https://gin-gonic.com/) · [GORM](https://gorm.io/) · [SQLite](https://www.sqlite.org/) |
| **Frontend** | [Vue 3](https://vuejs.org/) · [TypeScript](https://www.typescriptlang.org/) · [Vite](https://vitejs.dev/) · [Pinia](https://pinia.vuejs.org/) |
| **UI Kit** | [Element Plus](https://element-plus.org/) · [SCSS](https://sass-lang.com/) · [ECharts](https://echarts.apache.org/) · [UnoCSS](https://unocss.dev/) |
| **HTTP Client** | [Axios](https://axios-http.com/) · [Vue Router](https://router.vuejs.org/) |
| **i18n** | [vue-i18n](https://vue-i18n.intlify.dev/) |
| **CI/CD** | [GitHub Actions](https://github.com/features/actions) · [Docker](https://www.docker.com/) |

---

## 💻 Development

### Prerequisites

- Go (latest stable)
- Node.js (current LTS)
- pnpm

### Setup

```bash
# Clone the repository
git clone https://github.com/Mr-Javadian/honest-ui.git
cd honest-ui

# Frontend dependencies
cd frontend
pnpm install
pnpm exec vite build --mode production
cd ..

# Run backend (auto‑serves the built frontend)
go mod tidy
go run main.go
```

### Build from source

```bash
# Current platform
go build -o honest-ui -trimpath -ldflags "-s -w" main.go

# Cross‑compile examples
GOOS=linux GOARCH=amd64 go build -o honest-ui-linux-amd64 -trimpath -ldflags "-s -w" main.go
GOOS=linux GOARCH=arm64 go build -o honest-ui-linux-arm64 -trimpath -ldflags "-s -w" main.go
GOOS=linux GOARCH=arm GOARM=6 go build -o honest-ui-linux-armv6 -trimpath -ldflags "-s -w" main.go
```

---

## 📁 Project Structure

```
honest-ui/
│
├── frontend/                  # Vue 3 + TypeScript SPA
│   ├── src/
│   │   ├── api/               # Axios API clients
│   │   ├── assets/            # Images, fonts, static resources
│   │   ├── components/        # Shared Vue components
│   │   ├── lang/              # i18n locale files (en, zh-cn, ru)
│   │   ├── layout/            # App shell (Sidebar, Navbar, TagsView)
│   │   ├── router/            # Route definitions & guards
│   │   ├── store/             # Pinia stores (auth, tagsView, etc.)
│   │   ├── styles/            # Global SCSS variables & resets
│   │   ├── utils/             # Utility functions
│   │   └── views/             # Page components
│   └── public/                # Static assets (favicon, etc.)
│
├── api/                       # Go API request/response structures
├── cmd/                       # CLI commands (Cobra)
├── controller/                # HTTP request handlers
├── dao/                       # Database access layer (GORM)
├── middleware/                # Gin middleware (auth, rate‑limit, CORS)
├── model/                     # Data models, constants, DTOs, VOs
├── router/                    # Route registration
├── service/                   # Business logic
├── util/                      # Go utilities (version compare, download, etc.)
│
├── install.sh                 # One‑click installer script
├── Dockerfile                 # Container image definition
├── docker-compose.yml         # Docker Compose configuration
├── honest-ui.service           # systemd unit file
├── build.sh                   # Cross‑compilation script
└── build.bat                  # Windows build script
```

---

## 📋 System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | CentOS 8+, Ubuntu 20+, Debian 11+, or any modern Linux distribution |
| **Architecture** | `x86_64` / `amd64` · `aarch64` / `arm64` · `armv6` / `armv7` · `386` |
| **Memory** | Minimum 256 MB RAM |
| **Dependencies** | `curl` · `systemd` (for service) · `nftables` (auto‑installed) |
| **Storage** | ~100 MB for the binary + data |

---

## 🌍 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `H_UI_WEB_PORT` | `8081` | Panel web server port |
| `H_UI_WEB_CONTEXT` | `/` | URL context path (e.g. `/myhiddenpath`) |
| `H_UI_CRT_PATH` | — | Panel HTTPS certificate path |
| `H_UI_KEY_PATH` | — | Panel HTTPS private key path |
| `H_UI_HTTPS` | `0` | Enable panel HTTPS (`1` to enable) |
| `GIN_MODE` | `release` | Gin framework mode |
| `TZ` | `Asia/Tehran` | Server timezone |

All configurable from the Settings page in the UI, or via environment variables.

---

## 🔌 API Overview

The panel exposes a RESTful JSON API:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/login` | Authenticate |
| `GET` | `/api/monitor/system` | System resource usage |
| `GET` | `/api/monitor/hysteria2` | Hysteria 2 status |
| `GET/POST` | `/api/account/*` | User CRUD |
| `GET` | `/api/account/list` | List users (paginated) |
| `POST` | `/api/config/update` | Update panel config |
| `GET` | `/api/config/list` | Get panel config |
| `GET` | `/api/log/system` | System logs |
| `GET` | `/api/log/hysteria2` | Hysteria 2 logs |
| `POST` | `/api/hysteria2/*` | Hysteria 2 config & version management |

All API endpoints (except login) require a `Bearer` token obtained from `/api/login`.

---

## 🤝 Contributing

Contributions of all sizes are welcome — bug fixes, features, translations, documentation improvements.

1. Open an [issue](https://github.com/Mr-Javadian/honest-ui/issues) to discuss your proposed change
2. Fork the repository
3. Create a feature branch
4. Submit a pull request

### Translation guide

To add a new language:
1. Copy `frontend/src/lang/package/en.ts` → `{lang}.ts`
2. Translate all string values
3. Register the locale in `frontend/src/lang/index.ts`
4. Add the language name to page titles in `frontend/src/router/index.ts`

---

## 📄 License

[GPL-3.0](LICENSE) — Free to use, modify, and distribute. All changes must remain open source under the same license.

---

## 🙏 Acknowledgements

Honest-UI is a fork of [h-ui](https://github.com/jonssonyan/h-ui) by jonssonyan, itself inspired by [3x-ui](https://github.com/MHSanaei/3x-ui). Built on the shoulders of giants — thanks to the open‑source communities behind Go, Gin, GORM, Vue, Element Plus, Hysteria 2, and every library that makes this project possible.

---

## 📬 Support & Community

- **Bug reports & feature requests** — [GitHub Issues](https://github.com/Mr-Javadian/honest-ui/issues)
- **Discussion & help** — [GitHub Discussions](https://github.com/Mr-Javadian/honest-ui/discussions)
- **Security vulnerabilities** — Please open a private issue or contact the maintainer directly

---

<p align="center">
  <sub>Built with ❤️ for the Hysteria 2 community</sub>
  <br>
  <sub>If you find this project useful, consider giving it a ⭐</sub>
</p>
