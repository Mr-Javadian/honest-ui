#!/usr/bin/env bash
set -e
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

hui_systemd_version="${1:-latest}"
hui_docker_version=":${hui_systemd_version#v}"

# ────────────────────────────────────────────── Color ─────────────────────────────────────────────────────
ECHO_TYPE="echo -e"

echo_content() {
  case $1 in
    red)     ${ECHO_TYPE} "\033[31m$2\033[0m" ;;
    green)   ${ECHO_TYPE} "\033[32m$2\033[0m" ;;
    yellow)  ${ECHO_TYPE} "\033[33m$2\033[0m" ;;
    blue)    ${ECHO_TYPE} "\033[34m$2\033[0m" ;;
    purple)  ${ECHO_TYPE} "\033[35m$2\033[0m" ;;
    skyBlue) ${ECHO_TYPE} "\033[36m$2\033[0m" ;;
    white)   ${ECHO_TYPE} "\033[37m$2\033[0m" ;;
    bold)    ${ECHO_TYPE} "\033[1m$2\033[0m" ;;
  esac
}

# ────────────────────────────────────────────── Utility ────────────────────────────────────────────────────
init_var() {
  package_manager=""
  release=""
  version=""
  get_arch=""
  HUI_DATA_DOCKER="/honest-ui/"
  HUI_DATA_SYSTEMD="/usr/local/honest-ui/"
  h_ui_port=8081
  h_ui_time_zone=Asia/Tehran
  selected_ip=""
}

can_connect() {
  ping -c2 -i0.3 -W1 "$1" &>/dev/null
}

check_sys() {
  if [[ $(id -u) != "0" ]]; then
    echo_content red "You must be root to run this script"
    exit 1
  fi

  echo_content yellow "  [*] Checking network connection..."
  if ! can_connect github.com; then
    echo_content red "  [!] Network connection failed"
    exit 1
  fi
  echo_content green "  [\u2713] Network OK"

  echo_content yellow "  [*] Detecting package manager..."
  if   command -v dnf &>/dev/null;    then package_manager='dnf'
  elif command -v yum &>/dev/null;    then package_manager='yum'
  elif command -v apt-get &>/dev/null; then package_manager='apt-get'
  elif command -v apt &>/dev/null;    then package_manager='apt'
  fi
  [[ -z "${package_manager}" ]] && { echo_content red "  [!] Unsupported system"; exit 1; }
  echo_content green "  [\u2713] Package manager: ${package_manager}"

  echo_content yellow "  [*] Detecting OS..."
  if   grep -qi "rocky" /proc/version 2>/dev/null; then release="rocky"
  elif grep -qi "centos" /proc/version 2>/dev/null; then release="centos"
  elif grep -qi "debian" /etc/issue 2>/dev/null || grep -qi "debian" /proc/version 2>/dev/null; then release="debian"
  elif grep -qi "ubuntu" /etc/issue 2>/dev/null || grep -qi "ubuntu" /proc/version 2>/dev/null; then release="ubuntu"
  fi

  case $release in
    rocky|centos) version=$(rpm -q --queryformat '%{VERSION}' centos-stream-release 2>/dev/null || rpm -q --queryformat '%{VERSION}' centos-release 2>/dev/null || echo "") ;;
    debian)       version=$(cat /etc/debian_version 2>/dev/null) ;;
    ubuntu)       version=$(lsb_release -sr 2>/dev/null || grep VERSION_ID /etc/os-release 2>/dev/null | cut -d'"' -f2) ;;
    *)            echo_content red "  [!] Only CentOS/Ubuntu/Debian supported"; exit 1 ;;
  esac
  major_version=$(echo "${version}" | cut -d. -f1)

  echo_content green "  [\u2713] ${release^} ${version}"

  if [[ $(arch) =~ ("x86_64"|"amd64") ]]; then get_arch="amd64"
  elif [[ $(arch) =~ ("aarch64"|"arm64") ]]; then get_arch="arm64"
  else echo_content red "  [!] Only amd64/arm64 supported"; exit 1
  fi
  echo_content green "  [\u2713] Architecture: ${get_arch}"
}

install_depend() {
  echo_content yellow "  [*] Installing system dependencies..."
  if [[ "${package_manager}" == apt-get || "${package_manager}" == apt ]]; then
    ${package_manager} update -y -qq
  fi
  ${package_manager} install -y -q curl systemd nftables jq sqlite3 openssl 2>/dev/null || true
  echo_content green "  [\u2713] Dependencies installed"
}

# ────────────────────────────────────────────── System info ────────────────────────────────────────────────
get_system_info() {
  os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
  [[ -z "${os_info}" ]] && os_info="${release^} ${version}"
  echo "OS       : ${os_info}"
  echo "Arch     : ${get_arch}"
  echo "Kernel   : $(uname -r)"
  echo "Memory   : $(free -m | awk '/^Mem:/{print $2 "MiB"}')"
  echo "Disk     : $(df -BG / | awk 'NR==2{print $4}') free"
}

# ────────────────────────────────────────────── IP selection ──────────────────────────────────────────────
select_ip_address() {
  echo
  echo_content yellow "  \u2500\u2500 Network Interfaces \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  local ips=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && ips+=("$line")
  done < <(ip -4 addr show 2>/dev/null | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1')

  if [[ ${#ips[@]} -eq 0 ]]; then
    echo_content red "  [!] No external IP found (only 127.0.0.1)"
    read -r -p "  Enter your server IP manually: " selected_ip
    [[ -z "${selected_ip}" ]] && selected_ip="127.0.0.1"
    echo_content green "  [\u2713] Selected IP: ${selected_ip}"
    return
  fi

  local idx=1
  for ip in "${ips[@]}"; do
    local iface
    iface=$(ip -4 addr show 2>/dev/null | grep "inet ${ip}" | awk '{print $NF}')
    echo_content yellow "  [${idx}] ${ip}  (${iface})"
    ((idx++))
  done
  echo_content yellow "  [${idx}] Manual IP entry"
  echo
  read -r -p "  Select IP address [1-${idx}]: " ip_choice

  if [[ "${ip_choice}" == "${idx}" ]]; then
    read -r -p "  Enter custom IP address: " selected_ip
    [[ -z "${selected_ip}" ]] && selected_ip="${ips[0]}"
  elif [[ "${ip_choice}" =~ ^[0-9]+$ ]] && [[ "${ip_choice}" -ge 1 ]] && [[ "${ip_choice}" -lt "${idx}" ]]; then
    selected_ip="${ips[$((ip_choice-1))]}"
  else
    echo_content yellow "  [i] Using default: ${ips[0]}"
    selected_ip="${ips[0]}"
  fi
  echo_content green "  [\u2713] Selected IP: ${selected_ip}"
}

# ────────────────────────────────────────────── Random generators ──────────────────────────────────────────
generate_random_port() {
  while :; do
    local port=$(( ( RANDOM % 64511 ) + 1024 ))
    if ! ss -tlnp 2>/dev/null | grep -q ":${port} "; then
      echo "$port"
      return
    fi
  done
}

generate_strong_password() {
  local len=${1:-16}
  < /dev/urandom tr -dc 'A-Za-z0-9!@#%^&*()-_=+' | head -c "$len"
}

generate_context_path() {
  < /dev/urandom tr -dc 'a-zA-Z0-9' | head -c 19
}

setup_context_path() {
  local ctx_path="$1"
  local data_dir="$2"
  local db_path="${data_dir}data/h_ui.db"

  echo_content yellow "  [*] Setting up secure access path..."
  sleep 2  # wait for DB flush
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null; then
    sqlite3 "${db_path}" "INSERT OR REPLACE INTO config (key, value) VALUES ('H_UI_WEB_CONTEXT', '/${ctx_path}')" 2>/dev/null || true
    echo_content green "  [\u2713] Access path set to: /${ctx_path}"
  else
    echo_content yellow "  [!] Could not set access path (DB not ready)"
  fi
}

# ────────────────────────────────────────────── systemd install ────────────────────────────────────────────
install_h_ui_systemd() {
  if systemctl status honest-ui >/dev/null 2>&1; then
    echo_content red "  [!] Honest-UI is already installed"
    exit 0
  fi

  echo
  echo_content bold "  \u2501 Installing Honest-UI \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  echo_content yellow "  [*] Creating data directory..."
  mkdir -p "${HUI_DATA_SYSTEMD}"
  export HUI_DATA="${HUI_DATA_SYSTEMD}"
  sed -i '/^HUI_DATA=/d' /etc/environment 2>/dev/null || true
  echo "HUI_DATA=${HUI_DATA_SYSTEMD}" >> /etc/environment
  echo_content green "  [\u2713] Data directory: ${HUI_DATA_SYSTEMD}"

  select_ip_address

  local rand_port
  rand_port=$(generate_random_port)
  echo
  read -r -p "  Enter web panel port [default: ${rand_port}]: " h_ui_port
  [[ -z "${h_ui_port}" ]] && h_ui_port="${rand_port}"

  read -r -p "  Enter timezone [default: Asia/Tehran]: " h_ui_time_zone
  [[ -z "${h_ui_time_zone}" ]] && h_ui_time_zone="Asia/Tehran"

  echo_content yellow "  [*] Setting timezone..."
  timedatectl set-timezone "${h_ui_time_zone}" 2>/dev/null || true
  timedatectl set-local-rtc 0 2>/dev/null || true
  echo_content green "  [\u2713] Timezone: ${h_ui_time_zone}"

  echo_content yellow "  [*] Generating secure credentials..."
  local admin_user admin_pass con_pass ctx_path
  admin_user=$(generate_strong_password 12)
  admin_pass=$(generate_strong_password 20)
  con_pass="${admin_user}.${admin_pass}"
  ctx_path=$(generate_context_path)
  echo_content green "  [\u2713] Credentials generated"

  export GIN_MODE=release

  local bin_url="https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-${get_arch}"
  [[ "latest" != "${hui_systemd_version}" ]] && \
    bin_url="https://github.com/Mr-Javadian/honest-ui/releases/download/${hui_systemd_version}/honest-ui-linux-${get_arch}"

  echo_content yellow "  [*] Downloading Honest-UI binary..."
  curl -fsSL "${bin_url}" -o /usr/local/honest-ui/honest-ui
  chmod +x /usr/local/honest-ui/honest-ui
  echo_content green "  [\u2713] Binary downloaded"

  echo_content yellow "  [*] Installing systemd service..."
  cat > /etc/systemd/system/honest-ui.service <<SERVICEEOF
[Unit]
Description=Honest-UI Service
After=network.target
Wants=network.target

[Service]
Type=simple
WorkingDirectory=/usr/local/honest-ui/
Environment=HUI_DATA=/usr/local/honest-ui/
ExecStart=/usr/local/honest-ui/honest-ui -p ${h_ui_port}
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICEEOF
  systemctl daemon-reload
  systemctl enable honest-ui
  echo_content green "  [\u2713] Service installed & enabled"

  # First start to initialize DB
  echo_content yellow "  [*] First start (initializing database)..."
  systemctl start honest-ui
  sleep 3
  systemctl stop honest-ui
  sleep 1

  local db_path="${HUI_DATA_SYSTEMD}data/h_ui.db"

  # Set context path in DB
  echo_content yellow "  [*] Configuring secure access path..."
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null; then
    sqlite3 "${db_path}" "INSERT OR REPLACE INTO config (key, value) VALUES ('H_UI_WEB_CONTEXT', '/${ctx_path}')" 2>/dev/null || true
    echo_content green "  [\u2713] Access path: /${ctx_path}"
  else
    echo_content yellow "  [!] Could not set access path"
  fi

  # Set admin credentials in DB
  echo_content yellow "  [*] Setting admin credentials..."
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null && command -v openssl &>/dev/null; then
    local pass_hash
    pass_hash=$(echo -n "${admin_pass}" | openssl dgst -sha224 2>/dev/null | awk '{print $NF}')
    if [[ -n "${pass_hash}" ]]; then
      sqlite3 "${db_path}" "UPDATE account SET username='${admin_user}', pass='${pass_hash}', con_pass='${con_pass}' WHERE id=1" 2>/dev/null || true
      echo_content green "  [\u2713] Admin credentials configured"
    fi
  else
    echo_content yellow "  [!] Using default credentials (run 'honest-ui reset' to change)"
  fi

  # Set port in DB
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null; then
    sqlite3 "${db_path}" "INSERT OR REPLACE INTO config (key, value) VALUES ('H_UI_WEB_PORT', '${h_ui_port}')" 2>/dev/null || true
  fi

  # Final start
  echo_content yellow "  [*] Starting Honest-UI service..."
  systemctl start honest-ui
  sleep 3

  if systemctl is-active honest-ui >/dev/null 2>&1; then
    echo_content green "  [\u2713] Service started successfully"
  else
    echo_content yellow "  [!] Service not active, checking status..."
    systemctl status honest-ui --no-pager -l 2>&1 | tail -3 || true
    echo_content yellow "  [i] Retrying start..."
    systemctl restart honest-ui
    sleep 3
    if systemctl is-active honest-ui >/dev/null 2>&1; then
      echo_content green "  [\u2713] Service started on retry"
    else
      echo_content red "  [!] Service failed to start — run: journalctl -u honest-ui -n 50"
    fi
  fi

  echo
  echo_content bold "  \u2501 Installation Complete \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
  echo
  echo_content green "  Honest-UI Access URL:      http://${selected_ip}:${h_ui_port}/${ctx_path}"
  echo_content green "  Honest-UI Login Username:  ${admin_user}"
  echo_content green "  Honest-UI Login Password:  ${admin_pass}"
  echo_content green "  Honest-UI Connection Pass: ${con_pass}"
  echo
  echo_content yellow "  \u26a0 Save these credentials in a secure location!"
  echo
}

upgrade_h_ui_systemd() {
  if ! systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    echo_content red "  [!] Honest-UI not installed"
    exit 0
  fi

  echo
  echo_content bold "  \u2501 Upgrading Honest-UI \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  local current_version latest_version
  current_version=$(/usr/local/honest-ui/honest-ui -v 2>/dev/null | sed -n 's/.*version \([^\ ]*\).*/\1/p')
  latest_version=$(curl -fsSL "https://api.github.com/repos/Mr-Javadian/honest-ui/releases/latest" | grep '"tag_name":' | sed 's/.*"tag_name": "\(.*\)",.*/\1/')

  echo_content yellow "  [i] Current: ${current_version:-unknown}   Latest: ${latest_version:-unknown}"

  [[ "${latest_version}" == "${current_version}" ]] && { echo_content green "  [\u2713] Already up-to-date"; exit 0; }

  echo_content yellow "  [*] Stopping service..."
  systemctl stop honest-ui 2>/dev/null || true

  echo_content yellow "  [*] Downloading update..."
  curl -fsSL "https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-${get_arch}" -o /usr/local/honest-ui/honest-ui
  chmod +x /usr/local/honest-ui/honest-ui
  echo_content green "  [\u2713] Binary updated"

  echo_content yellow "  [*] Starting service..."
  systemctl restart honest-ui
  sleep 2

  systemctl is-active honest-ui >/dev/null 2>&1 \
    && echo_content green "  [\u2713] Upgrade successful" \
    || echo_content red "  [!] Service failed to start"
}

uninstall_h_ui_systemd() {
  if ! systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    echo_content red "  [!] Honest-UI not installed"
    exit 0
  fi

  echo
  echo_content bold "  \u2501 Uninstalling Honest-UI \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  echo_content yellow "  [*] Stopping service..."
  systemctl stop honest-ui 2>/dev/null || true

  echo_content yellow "  [*] Disabling & removing service..."
  systemctl disable honest-ui.service 2>/dev/null || true
  rm -f /etc/systemd/system/honest-ui.service
  systemctl daemon-reload
  systemctl reset-failed 2>/dev/null || true

  echo_content yellow "  [*] Removing data..."
  rm -rf /usr/local/honest-ui/
  sed -i '/^HUI_DATA=/d' /etc/environment 2>/dev/null || true
  remove_forward

  echo_content green "  [\u2713] Honest-UI uninstalled"
}

# ────────────────────────────────────────────── Docker ─────────────────────────────────────────────────────
setup_docker_daemon() {
  mkdir -p /etc/docker
  cat >/etc/docker/daemon.json <<EOF
{ "log-driver": "json-file", "log-opts": { "max-size": "100m" } }
EOF
  systemctl daemon-reload
}

install_docker_engine() {
  if command -v docker &>/dev/null; then
    echo_content green "  [\u2713] Docker already installed"
    return
  fi
  echo_content yellow "  [*] Installing Docker..."
  bash <(curl -fsSL https://get.docker.com)
  setup_docker_daemon
  systemctl enable docker && systemctl restart docker
  command -v docker &>/dev/null || { echo_content red "  [!] Docker install failed"; exit 1; }
  echo_content green "  [\u2713] Docker installed"
}

install_h_ui_docker() {
  docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q . && { echo_content red "  [!] Honest-UI already installed"; exit 0; }

  echo
  echo_content bold "  \u2501 Installing Honest-UI \u2500 Docker \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  install_docker_engine
  mkdir -p "${HUI_DATA_DOCKER}"

  select_ip_address

  local rand_port
  rand_port=$(generate_random_port)
  echo
  read -r -p "  Enter web panel port [default: ${rand_port}]: " h_ui_port
  [[ -z "${h_ui_port}" ]] && h_ui_port="${rand_port}"

  read -r -p "  Enter timezone [default: Asia/Tehran]: " h_ui_time_zone
  [[ -z "${h_ui_time_zone}" ]] && h_ui_time_zone="Asia/Tehran"

  local admin_user admin_pass con_pass ctx_path
  admin_user=$(generate_strong_password 12)
  admin_pass=$(generate_strong_password 20)
  con_pass="${admin_user}.${admin_pass}"
  ctx_path=$(generate_context_path)

  echo_content yellow "  [*] Starting Docker container..."
  docker run -d --cap-add=NET_ADMIN \
    --name honest-ui --restart always \
    --network=host \
    -e TZ="${h_ui_time_zone}" \
    -v /honest-ui/bin:/honest-ui/bin \
    -v /honest-ui/data:/honest-ui/data \
    -v /honest-ui/export:/honest-ui/export \
    -v /honest-ui/logs:/honest-ui/logs \
    mr-javadian/honest-ui"${hui_docker_version}" \
    ./honest-ui -p "${h_ui_port}"
  sleep 4

  local db_path="${HUI_DATA_DOCKER}data/h_ui.db"

  # Configure context path and credentials
  echo_content yellow "  [*] Configuring access path..."
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null; then
    sqlite3 "${db_path}" "INSERT OR REPLACE INTO config (key, value) VALUES ('H_UI_WEB_CONTEXT', '/${ctx_path}')" 2>/dev/null || true
    echo_content green "  [\u2713] Access path: /${ctx_path}"
  fi

  echo_content yellow "  [*] Setting admin credentials..."
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null && command -v openssl &>/dev/null; then
    local pass_hash
    pass_hash=$(echo -n "${admin_pass}" | openssl dgst -sha224 2>/dev/null | awk '{print $NF}')
    if [[ -n "${pass_hash}" ]]; then
      sqlite3 "${db_path}" "UPDATE account SET username='${admin_user}', pass='${pass_hash}', con_pass='${con_pass}' WHERE id=1" 2>/dev/null || true
      sqlite3 "${db_path}" "INSERT OR REPLACE INTO config (key, value) VALUES ('H_UI_WEB_PORT', '${h_ui_port}')" 2>/dev/null || true
      echo_content green "  [\u2713] Admin credentials configured"
    fi
  fi

  echo_content yellow "  [*] Restarting container with new config..."
  docker restart honest-ui 2>/dev/null || true
  sleep 2

  echo
  echo_content bold "  \u2501 Installation Complete \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
  echo
  echo_content green "  Honest-UI Access URL:      http://${selected_ip}:${h_ui_port}/${ctx_path}"
  echo_content green "  Honest-UI Login Username:  ${admin_user}"
  echo_content green "  Honest-UI Login Password:  ${admin_pass}"
  echo_content green "  Honest-UI Connection Pass: ${con_pass}"
  echo
  echo_content yellow "  \u26a0 Save these credentials in a secure location!"
  echo
}

upgrade_h_ui_docker() {
  command -v docker &>/dev/null || { echo_content red "  [!] Docker not installed"; exit 0; }
  docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q . || { echo_content red "  [!] Honest-UI not installed"; exit 0; }

  echo
  echo_content bold "  \u2501 Upgrading Honest-UI \u2500 Docker \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  local latest_version current_version
  latest_version=$(curl -fsSL "https://api.github.com/repos/Mr-Javadian/honest-ui/releases/latest" | grep '"tag_name":' | sed 's/.*"tag_name": "\(.*\)",.*/\1/')
  current_version=$(docker exec honest-ui ./honest-ui -v 2>/dev/null | sed -n 's/.*version \([^\ ]*\).*/\1/p')
  echo_content yellow "  [i] Current: ${current_version:-unknown}   Latest: ${latest_version:-unknown}"

  [[ "${latest_version}" == "${current_version}" ]] && { echo_content green "  [\u2713] Already up-to-date"; exit 0; }

  echo_content yellow "  [*] Removing old container..."
  docker rm -f honest-ui
  docker rmi mr-javadian/honest-ui 2>/dev/null || true

  echo_content yellow "  [*] Deploying new version..."
  docker run -d --cap-add=NET_ADMIN \
    --name honest-ui --restart always \
    --network=host \
    -e TZ="${h_ui_time_zone}" \
    -v /honest-ui/bin:/honest-ui/bin \
    -v /honest-ui/data:/honest-ui/data \
    -v /honest-ui/export:/honest-ui/export \
    -v /honest-ui/logs:/honest-ui/logs \
    mr-javadian/honest-ui \
    ./honest-ui -p "${h_ui_port}"
  sleep 2

  echo_content green "  [\u2713] Upgrade successful"
}

uninstall_h_ui_docker() {
  command -v docker &>/dev/null || { echo_content red "  [!] Docker not installed"; exit 0; }
  docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q . || { echo_content red "  [!] Honest-UI not installed"; exit 0; }

  echo
  echo_content bold "  \u2501 Uninstalling Honest-UI \u2500 Docker \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  echo_content yellow "  [*] Removing container..."
  docker rm -f honest-ui

  echo_content yellow "  [*] Removing image..."
  docker images mr-javadian/honest-ui -q | xargs -r docker rmi -f

  echo_content yellow "  [*] Removing data..."
  rm -rf /honest-ui/
  remove_forward

  echo_content green "  [\u2713] Uninstall complete"
}

# ────────────────────────────────────────────── Extra ──────────────────────────────────────────────────────
remove_forward() {
  if command -v nft &>/dev/null && nft list tables 2>/dev/null | grep -q hui_porthopping; then
    nft delete table inet hui_porthopping 2>/dev/null || true
  fi
  for cmd in iptables ip6tables; do
    command -v "$cmd" &>/dev/null && \
      $cmd -t nat -L PREROUTING -v --line-numbers 2>/dev/null | grep -i "hui_hysteria_porthopping" | awk '{print $1}' | sort -rn | while read -r num; do
        $cmd -t nat -D PREROUTING "$num" 2>/dev/null || true
      done
  done
}

change_web_port() {
  echo
  echo_content bold "  \u2501 Change Web Panel Port \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  local current_port="" db_path=""

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    db_path="${HUI_DATA_SYSTEMD}data/h_ui.db"
    [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null && \
      current_port=$(sqlite3 "${db_path}" "SELECT value FROM config WHERE key='H_UI_WEB_PORT'" 2>/dev/null)
    [[ -z "${current_port}" ]] && current_port=$(grep -oP '(?<=-p )\d+' /etc/systemd/system/honest-ui.service 2>/dev/null || echo "8081")
  elif command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    db_path="${HUI_DATA_DOCKER}data/h_ui.db"
    [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null && \
      current_port=$(sqlite3 "${db_path}" "SELECT value FROM config WHERE key='H_UI_WEB_PORT'" 2>/dev/null)
    [[ -z "${current_port}" ]] && current_port="8081"
  else
    echo_content red "  [!] Honest-UI not installed"
    return
  fi

  echo_content yellow "  [i] Current port: ${current_port}"
  read -r -p "  Enter new port [1-65535]: " new_port
  [[ -z "${new_port}" ]] && { echo_content yellow "  [i] No change"; return; }
  [[ ! "${new_port}" =~ ^[0-9]+$ || "${new_port}" -lt 1 || "${new_port}" -gt 65535 ]] && { echo_content red "  [!] Invalid port"; return; }

  if ss -tlnp 2>/dev/null | grep -q ":${new_port} "; then
    echo_content yellow "  [!] Port ${new_port} is in use"
    read -r -p "  Continue? [y/N]: " ans
    [[ "${ans}" != "y" && "${ans}" != "Y" ]] && return
  fi

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    echo_content yellow "  [*] Updating systemd service..."
    sed -i "s|-p [0-9]*|-p ${new_port}|" /etc/systemd/system/honest-ui.service
    systemctl daemon-reload
    systemctl restart honest-ui
    echo_content green "  [\u2713] Port changed"
  fi

  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    echo_content yellow "  [*] Recreating Docker container..."
    docker rm -f honest-ui
    docker run -d --cap-add=NET_ADMIN \
      --name honest-ui --restart always --network=host \
      -e TZ="${h_ui_time_zone}" \
      -v /honest-ui/bin:/honest-ui/bin \
      -v /honest-ui/data:/honest-ui/data \
      -v /honest-ui/export:/honest-ui/export \
      -v /honest-ui/logs:/honest-ui/logs \
      mr-javadian/honest-ui ./honest-ui -p "${new_port}"
    echo_content green "  [\u2713] Docker port changed"
  fi

  if command -v sqlite3 &>/dev/null && [[ -f "${db_path}" ]]; then
    sqlite3 "${db_path}" "INSERT OR REPLACE INTO config (key, value) VALUES ('H_UI_WEB_PORT', '${new_port}')" 2>/dev/null || true
  fi

  echo_content green "  [\u2713] Port updated to ${new_port}"
  sleep 1
}

reset_sysadmin() {
  echo
  echo_content bold "  \u2501 Reset Admin Password \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    export HUI_DATA="${HUI_DATA_SYSTEMD}"
    echo_content yellow "  [*] Resetting (systemd)..."
    echo_content yellow "  $(${HUI_DATA_SYSTEMD}honest-ui reset 2>/dev/null || echo 'Reset command unavailable')"
    systemctl restart honest-ui
    echo_content green "  [\u2713] Done (systemd)"
  fi

  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    echo_content yellow "  [*] Resetting (Docker)..."
    echo_content yellow "  $(docker exec honest-ui ./honest-ui reset 2>/dev/null || echo 'Reset command unavailable')"
    docker restart honest-ui 2>/dev/null || true
    echo_content green "  [\u2713] Done (Docker)"
  fi
}

view_status() {
  echo
  echo_content bold "  \u2501 Honest-UI Status \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  local found=false

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    found=true
    echo
    echo_content bold "  \u2500\u2500 systemd \u2500\u2500"
    local status
    status=$(systemctl is-active honest-ui 2>/dev/null || echo "inactive")
    if [[ "${status}" == "active" ]]; then echo_content green "  \u25cf Running"
    else echo_content red "  \u25cf ${status}"; fi

    if [[ -f "${HUI_DATA_SYSTEMD}data/h_ui.db" ]] && command -v sqlite3 &>/dev/null; then
      echo_content yellow "  Port: $(sqlite3 "${HUI_DATA_SYSTEMD}data/h_ui.db" "SELECT value FROM config WHERE key='H_UI_WEB_PORT'" 2>/dev/null || echo "N/A")"
      echo_content yellow "  Path: $(sqlite3 "${HUI_DATA_SYSTEMD}data/h_ui.db" "SELECT value FROM config WHERE key='H_UI_WEB_CONTEXT'" 2>/dev/null || echo "/")"
    fi
    systemctl status honest-ui --no-pager -l 2>&1 | head -5
  fi

  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    found=true
    echo
    echo_content bold "  \u2500\u2500 Docker \u2500\u2500"
    local status
    status=$(docker inspect honest-ui --format '{{.State.Status}}' 2>/dev/null || echo "not found")
    if [[ "${status}" == "running" ]]; then echo_content green "  \u25cf Running"
    else echo_content red "  \u25cf ${status}"; fi

    if [[ -f "${HUI_DATA_DOCKER}data/h_ui.db" ]] && command -v sqlite3 &>/dev/null; then
      echo_content yellow "  Port: $(sqlite3 "${HUI_DATA_DOCKER}data/h_ui.db" "SELECT value FROM config WHERE key='H_UI_WEB_PORT'" 2>/dev/null || echo "N/A")"
      echo_content yellow "  Path: $(sqlite3 "${HUI_DATA_DOCKER}data/h_ui.db" "SELECT value FROM config WHERE key='H_UI_WEB_CONTEXT'" 2>/dev/null || echo "/")"
    fi
  fi

  ${found} || echo_content yellow "  Honest-UI is not installed"

  echo
  read -r -p "  Press Enter to continue..."
}

ssh_local_port_forwarding() {
  echo
  echo_content bold "  \u2501 SSH Local Port Forwarding \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"

  read -r -p "  SSH forwarding port [default: 8082]: " fwd_port
  [[ -z "${fwd_port}" ]] && fwd_port="8082"
  read -r -p "  Honest-UI port [default: 8081]: " ui_port
  [[ -z "${ui_port}" ]] && ui_port="8081"
  ssh -N -f -L 0.0.0.0:"${fwd_port}":localhost:"${ui_port}" localhost
  echo_content green "  [\u2713] Forwarding 0.0.0.0:${fwd_port} -> localhost:${ui_port}"
}

# ────────────────────────────────────────────── Main ───────────────────────────────────────────────────────
main() {
  cd "$HOME" || exit 0
  init_var
  check_sys
  install_depend

  while :; do
    clear

    # ── Banner ──
    cat <<'BANNER'

  ╔═══════════════════════════════════════════════════╗
  ║                                                   ║
  ║   ██╗  ██╗ ██████╗ ███╗   ██╗███████╗███████╗████████╗
  ║   ██║  ██║██╔═══██╗████╗  ██║██╔════╝██╔════╝╚══██╔══╝
  ║   ███████║██║   ██║██╔██╗ ██║█████╗  ███████╗   ██║
  ║   ██╔══██║██║   ██║██║╚██╗██║██╔══╝  ╚════██║   ██║
  ║   ██║  ██║╚██████╔╝██║ ╚████║███████╗███████║   ██║
  ║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝   ╚═╝
  ║                                                   ║
  ║        Hysteria 2 Management Panel                ║
BANNER
    printf "  ║        Version %-37s║\n" "${hui_systemd_version}"
    echo "  ╚═══════════════════════════════════════════════════╝"
    echo

    # ── System Info ──
    echo "  ┌─ System Information ─────────────────────────────────────┐"
    while IFS= read -r line; do
      printf "  │  %-54s │\n" "$line"
    done < <(get_system_info)
    echo "  └──────────────────────────────────────────────────────────┘"
    echo

    # ── Menu ──
    echo "  Welcome to Honest-UI Installer"
    echo
    echo "  [1]  Install Panel — (systemd)"
    echo "  [2]  Upgrade Panel — (systemd)"
    echo "  [3]  Uninstall — Remove completely (systemd)"
    echo "  ---------------------------------------------------"
    echo "  [4]  Install Panel — (Docker)"
    echo "  [5]  Upgrade Panel — (Docker)"
    echo "  [6]  Uninstall — Remove completely (Docker)"
    echo "  ---------------------------------------------------"
    echo "  [7]  Reset Panel admin password"
    echo "  [8]  Change Ports"
    echo "  [9]  View Details & Status"
    echo "  ---------------------------------------------------"
    echo "  [0]  Exit"
    echo
    read -r -p "  Enter your choice [0-9]: " input_option
    echo

    case ${input_option} in
      1) install_h_ui_systemd ;;
      2) upgrade_h_ui_systemd ;;
      3) uninstall_h_ui_systemd ;;
      4) install_h_ui_docker ;;
      5) upgrade_h_ui_docker ;;
      6) uninstall_h_ui_docker ;;
      7) reset_sysadmin ;;
      8) change_web_port ;;
      9) view_status ;;
      0) echo_content green "  Goodbye!"; exit 0 ;;
      *) echo_content red "  [!] Invalid option 0-9"; sleep 1.5 ;;
    esac
  done
}

main
