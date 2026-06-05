<div align="center">
  <img src="https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/frontend/src/assets/logo.png" alt="Honest-UI" width="80" height="80" style="border-radius: 16px">

  <h1 align="center">Honest-UI</h1>

  <p align="center">
    <strong>Modern, open-source management panel for Hysteria 2</strong>
    <br>
    Lightweight · Fast · Feature-rich · Beautiful
  </p>

  <p>
    <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="License: GPL-3.0"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/releases"><img src="https://img.shields.io/github/v/release/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="GitHub release"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/stargazers"><img src="https://img.shields.io/github/stars/Mr-Javadian/honest-ui?style=flat-square&color=6366f1" alt="GitHub stars"></a>
    <a href="https://github.com/Mr-Javadian/honest-ui/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/Mr-Javadian/honest-ui/release.yml?style=flat-square&color=6366f1" alt="Build status"></a>
  </p>

  <p>
    <a href="./README.md">English</a> ·
    <a href="./README_zh-CN.md">简体中文</a> ·
    <a href="./README_RU.md">Русский</a>
  </p>
</div>

---

## ✨ Features

- **🚀 One-Click Install** — Automated install script with systemd & Docker support, random secure credentials, IP selection, and context path generation
- **📊 Real-Time Monitoring** — System resource usage (CPU, memory, disk) and Hysteria 2 status dashboard
- **👥 User Management** — Traffic quota, bandwidth tracking, online status, device limits, kick/force offline, import/export users
- **🔗 Subscription Support** — Auto-generated subscription links & QR codes, node URLs, Clash-compatible subscriptions
- **⚙️ Full Hysteria 2 Control** — Config editor with all Hysteria 2 options, version switching, port hopping, ACL, outbounds, TLS/ACME, obfuscation
- **🔐 Security First** — Random admin credentials on install, context-path hiding, JWT authentication, password hashing (SHA-224)
- **🌐 Multi-Language** — English, 简体中文, Русский
- **🎨 Modern UI** — Glassmorphism design, dark mode, animated transitions, responsive layout, Catppuccin-inspired color scheme
- **🤖 Telegram Integration** — Login alerts, bot notifications
- **🔧 CLI Management Menu** — Full management via terminal: reset password, change ports, view status, uninstall

## 🖥️ Quick Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

The installer will:
1. Detect your OS & architecture
2. Let you select the panel port (or auto-generate)
3. Let you choose the web interface IP
4. Generate random strong credentials (12-char username, 20-char password)
5. Create a random context path (e.g., `/KvEi6CQpIWPa7WHnEf5`)
6. Install as a systemd service or Docker container
7. Print access URL and credentials

After installation, type `honest-ui` to open the management menu.

## 📦 Manual Installation

### systemd

```bash
mkdir -p /usr/local/honest-ui/
curl -fsSL https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-amd64 \
  -o /usr/local/honest-ui/honest-ui && chmod +x /usr/local/honest-ui/honest-ui
curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/honest-ui.service \
  -o /etc/systemd/system/honest-ui.service
systemctl daemon-reload && systemctl enable honest-ui && systemctl restart honest-ui
```

### Docker

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

## 🏗️ System Requirements

| Component | Requirement |
|-----------|-------------|
| OS | CentOS 8+, Ubuntu 20+, Debian 11+ |
| Architecture | `x86_64` / `amd64` or `aarch64` / `arm64` |
| Memory | ≥ 256 MB |
| Dependencies | `curl`, `systemd`, `nftables`, `sqlite3`, `openssl` (auto-installed) |

## 🔧 Management Menu

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

## 🛠️ Development

### Prerequisites

- Go ≥ 1.21
- Node.js ≥ 18.12.0
- pnpm ≥ 9

### Frontend

```bash
cd frontend
pnpm install
pnpm exec vite build --mode production
```

### Backend

```bash
go run main.go
```

### Build from source

```bash
# Build for current platform
go build -o honest-ui main.go

# Cross-compile for Linux amd64
GOOS=linux GOARCH=amd64 go build -o honest-ui-linux-amd64 main.go

# Cross-compile for Linux arm64
GOOS=linux GOARCH=arm64 go build -o honest-ui-linux-arm64 main.go
```

## 📁 Project Structure

```
honest-ui/
├── frontend/          # Vue 3 + Element Plus + TypeScript
│   └── src/
│       ├── api/       # API clients
│       ├── assets/    # Icons, images, styles
│       ├── components/# Shared components
│       ├── lang/      # i18n translations (en, ru, zh-cn)
│       ├── layout/    # App layout (sidebar, navbar, tags)
│       ├── router/    # Route definitions
│       ├── store/     # Pinia state management
│       ├── styles/    # Global SCSS
│       ├── utils/     # Helpers
│       └── views/     # Page components
├── api/               # Go API handlers
├── cmd/               # CLI commands
├── controller/        # HTTP controllers
├── dao/               # Database access
├── middleware/        # Gin middleware (auth, rate-limit, etc.)
├── model/             # Data models, constants, DTOs/VOs
├── router/            # Route registration
├── service/           # Business logic
└── util/              # Go utilities
```

## 📄 License

This project is licensed under the [GPL-3.0 License](LICENSE).

## 🙏 Credits

This project is a fork of [h-ui](https://github.com/jonssonyan/h-ui) by jonssonyan, released under GPL-3.0.

## 💬 Support

- [GitHub Issues](https://github.com/Mr-Javadian/honest-ui/issues) — Bug reports & feature requests
