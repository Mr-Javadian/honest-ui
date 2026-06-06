<div align="center">
  <img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/frontend/src/assets/logo.png" alt="Honest-UI" width="80" height="80" style="border-radius: 16px">

  <h1 align="center">Honest-UI</h1>

  <p align="center">
    <strong>Modern, open-source management panel for Hysteria 2</strong>
    <br>
    Lightweight · Fast · Feature-rich · Beautiful
  </p>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="License"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/releases"><img src="https://img.shields.io/github/v/release/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="Release"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/stargazers"><img src="https://img.shields.io/github/stars/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="Stars"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/Mr-Javadian/honest-ui/release.yml?style=flat-square&color=6366f1" alt="Build"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/commit"><img src="https://img.shields.io/github/last-commit/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="Last Commit"></a>
    <a href="https://go.dev/"><img src="https://img.shields.io/github/go-mod/go-version/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="Go"></a>
  </p>

  <p>
    <a href="./README.md">English</a> ·
    <a href="./README_zh-CN.md">简体中文</a> ·
    <a href="./README_RU.md">Русский</a>
  </p>
</div>

---

## Quick Start

**One-command installation:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

After installation, type `honest-ui` to open the management menu.

---

## Features

| Category | Capabilities |
|----------|--------------|
| **🚀 One-Click Install** | systemd & Docker support, random secure credentials, IP selection, auto context-path |
| **📊 Real-Time Monitor** | CPU / Memory / Disk usage, Hysteria 2 status dashboard |
| **👥 User Management** | Traffic quota, bandwidth tracking, online status, device limits, kick/offline, bulk import/export |
| **🔗 Subscription** | Auto-generated links & QR codes, Clash-compatible subscriptions, node URLs |
| **⚙️ Hysteria 2 Control** | Full config editor, version switching, port hopping, ACL, outbounds, TLS/ACME, obfuscation |
| **🔐 Security** | Random admin credentials, context-path hiding, JWT auth, SHA-224 password hashing |
| **🌐 Multi-Language** | English, 简体中文, Русский |
| **🎨 Modern UI** | Glassmorphism design, animated transitions, responsive layout, Catppuccin-inspired palette |
| **🤖 Telegram Bot** | Login alerts, custom notification templates |
| **🔧 CLI Menu** | Full terminal management: reset password, change ports, view status, uninstall |

---

## Screenshots

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/login.png" alt="Login" width="400"/></td>
    <td><img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/docs/screenshots/dashboard.png" alt="Dashboard" width="400"/></td>
  </tr>
  <tr>
    <td align="center"><em>Login Page</em></td>
    <td align="center"><em>System Dashboard</em></td>
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

## Installation

### Option 1: Quick Install (Recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

The installer handles everything:
1. Detects OS & architecture
2. Prompts for panel port (or auto-generates)
3. Lets you choose web interface IP
4. Generates random credentials (12-char username, 20-char password)
5. Creates a random context path (e.g., `/KvEi6CQpIWPa7WHnEf5`)
6. Installs as systemd service or Docker container
7. Prints access URL and credentials

### Option 2: Manual (systemd)

```bash
mkdir -p /usr/local/honest-ui/
curl -fsSL https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-amd64 \
  -o /usr/local/honest-ui/honest-ui && chmod +x /usr/local/honest-ui/honest-ui
curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/honest-ui.service \
  -o /etc/systemd/system/honest-ui.service
systemctl daemon-reload && systemctl enable honest-ui && systemctl restart honest-ui
```

### Option 3: Docker

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

---

## Management Menu

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

## System Requirements

| Component | Requirement |
|-----------|-------------|
| OS | CentOS 8+, Ubuntu 20+, Debian 11+ |
| Architecture | `x86_64` / `amd64` or `aarch64` / `arm64` |
| Memory | ≥ 256 MB |
| Dependencies | `curl`, `systemd`, `nftables`, `sqlite3`, `openssl` (auto-installed) |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **Backend** | [Go](https://go.dev/) 1.22+ · [Gin](https://gin-gonic.com/) · [GORM](https://gorm.io/) · [SQLite](https://www.sqlite.org/) |
| **Frontend** | [Vue 3](https://vuejs.org/) · [TypeScript](https://www.typescriptlang.org/) · [Vite](https://vitejs.dev/) |
| **UI** | [Element Plus](https://element-plus.org/) · [SCSS](https://sass-lang.com/) · [ECharts](https://echarts.apache.org/) |
| **State** | [Pinia](https://pinia.vuejs.org/) · [Vue Router](https://router.vuejs.org/) |
| **Runtime** | [Node.js](https://nodejs.org/) ≥ 20 · [pnpm](https://pnpm.io/) |

---

## Development

### Prerequisites

- Go ≥ 1.22
- Node.js ≥ 20.0.0
- pnpm ≥ 9

### Frontend

```bash
cd frontend
pnpm install
pnpm exec vite build --mode production
```

### Backend

```bash
go mod tidy
go run main.go
```

### Build from source

```bash
# Single platform
go build -o honest-ui main.go

# Cross-compile (Linux amd64)
GOOS=linux GOARCH=amd64 go build -o honest-ui-linux-amd64 main.go

# Cross-compile (Linux arm64)
GOOS=linux GOARCH=arm64 go build -o honest-ui-linux-arm64 main.go
```

---

## Project Structure

```
honest-ui/
├── frontend/                # Vue 3 + TypeScript SPA
│   ├── src/
│   │   ├── api/             # HTTP API clients
│   │   ├── assets/          # Static resources
│   │   ├── components/      # Reusable components
│   │   ├── lang/            # i18n (en, ru, zh-cn)
│   │   ├── layout/          # App shell (sidebar, navbar, tags)
│   │   ├── router/          # Route definitions
│   │   ├── store/           # Pinia stores
│   │   ├── styles/          # Global SCSS
│   │   ├── utils/           # Utilities
│   │   └── views/           # Page components
│   └── public/              # Static assets (favicon, etc.)
├── api/                     # Go API layer
├── cmd/                     # CLI commands
├── controller/              # HTTP controllers
├── dao/                     # Database access
├── middleware/              # Gin middleware
├── model/                   # Data models & DTOs
├── router/                  # Route registration
├── service/                 # Business logic
├── util/                    # Go utilities
├── install.sh               # One-click installer
├── Dockerfile               # Container image
└── docker-compose.yml       # Docker Compose config
```

---

## Version Upgrade Notes

### Upgrading to v0.4.4

This release includes dependency version bumps:

| Dependency | Before | After |
|------------|--------|-------|
| Go | 1.21 | 1.22 |
| Node.js (min) | 18.12 | 20.0 |
| Gin | v1.9.1 | v1.10.0 |
| GORM | v1.25.9 | v1.31.1 |
| Cobra | v1.8.1 | v1.9.1 |
| validator | v10.14.0 | v10.23.0 |
| Vue | 3.2.x | 3.5.x |
| Element Plus | 2.3.x | 2.9.x |
| Vite | 4.3.x | 4.5.x |
| TypeScript | 4.9.x | 4.9.x |

After pulling sources, run:
```bash
go mod tidy          # Update Go dependencies
cd frontend && pnpm install  # Update frontend dependencies
```

---

## Contributing

Contributions are welcome! Please open an [issue](https://github.com/Mr-Javadian/honest-ui/issues) first to discuss changes.

---

## License

[GPL-3.0 License](LICENSE)

---

## Credits

This project is a fork of [h-ui](https://github.com/jonssonyan/h-ui) by jonssonyan, released under GPL-3.0.

---

## Support

- [GitHub Issues](https://github.com/Mr-Javadian/honest-ui/issues) — Bug reports & feature requests
