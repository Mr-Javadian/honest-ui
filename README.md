<div align="center">

<h1 align="center">Honest-UI</h1>

English

> Just the panel for Hysteria2 — Modern, fast, and open-source management panel.

<p>
<a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/github/license/Mr-Javadian/honest-ui" alt="License: GPL-3.0"></a>
<a href="https://github.com/Mr-Javadian/honest-ui/stargazers"><img src="https://img.shields.io/github/stars/Mr-Javadian/honest-ui" alt="GitHub stars"></a>
<a href="https://github.com/Mr-Javadian/honest-ui/forks"><img src="https://img.shields.io/github/forks/Mr-Javadian/honest-ui" alt="GitHub forks"></a>
<a href="https://github.com/Mr-Javadian/honest-ui/releases"><img src="https://img.shields.io/github/v/release/Mr-Javadian/honest-ui" alt="GitHub release"></a>
</p>

</div>

## Features

- Lightweight, low resource usage, easy to deploy
- Monitor system status and Hysteria2 status
- Limit user traffic, user online status, force users to log off, number of online users, reset user traffic
- Limit the number of users' online devices at the same time, number of online devices
- User subscription link, node URL, import and export users
- Managing Hysteria2 configurations and Hysteria2 versions, port hopping
- Change the Web port, modify the Hysteria2 traffic multiplier
- Telegram notification
- View, import, and export system logs and Hysteria2 logs
- I18n: English, 简体中文, Русский
- Page adaptation, support night mode, custom page themes
- Modern UI with glassmorphism design
- More features waiting for you to discover

## Recommended OS

OS: CentOS 8+/Ubuntu 20+/Debian 11+

CPU: x86_64/amd64 arm64/aarch64

Memory: ≥ 256MB

## Deployment

### Quick Install (Recommended)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh)
```

### systemd

```bash
mkdir -p /usr/local/honest-ui/
curl -fsSL https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-amd64 -o /usr/local/honest-ui/honest-ui && chmod +x /usr/local/honest-ui/honest-ui
curl -fsSL https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/honest-ui.service -o /etc/systemd/system/honest-ui.service
systemctl daemon-reload
systemctl enable honest-ui
systemctl restart honest-ui
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

## Default Installation Information

- Panel Port: 8081
- Login Username/Password: Random 6 characters
- Connection Password: {Login Username}.{Login Password}

## Performance Optimization

- Scheduled server restart

    ```bash
    0 4 * * * /sbin/reboot
    ```

## Development

Go >= 1.20, Node.js >= 18.12.0

### Frontend

```bash
cd frontend
pnpm install
npm run dev
```

### Backend

```bash
go run main.go
```

## License

[GPL-3.0](LICENSE)

## Credits

This project is a fork of [h-ui](https://github.com/jonssonyan/h-ui) by jonssonyan.