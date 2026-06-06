#!/usr/bin/env bash
set -e
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

hui_systemd_version="${1:-latest}"
hui_docker_version=":${hui_systemd_version#v}"
hui_script_version="v0.4.6"

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
  major_version=""
}

can_connect() {
  ping -c2 -i0.3 -W1 "$1" &>/dev/null
}

detect_system() {
  [[ $(id -u) != "0" ]] && { echo_content red "  [!] You must be root"; exit 1; }

  echo "  [*] Checking network connection..."
  can_connect github.com || { echo_content red "  [!] Network connection failed"; exit 1; }
  echo -e "  [\xE2\x9C\x93] Network OK"

  echo "  [*] Detecting package manager..."
  if   command -v dnf &>/dev/null;    then package_manager='dnf'
  elif command -v yum &>/dev/null;    then package_manager='yum'
  elif command -v apt-get &>/dev/null; then package_manager='apt-get'
  elif command -v apt &>/dev/null;    then package_manager='apt'
  fi
  [[ -z "${package_manager}" ]] && { echo_content red "  [!] Unsupported package manager"; exit 1; }
  echo -e "  [\xE2\x9C\x93] Package manager: ${package_manager}"

  echo "  [*] Detecting OS..."
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
  echo -e "  [\xE2\x9C\x93] ${release^} ${version}"

  if [[ $(arch) =~ ("x86_64"|"amd64") ]]; then get_arch="amd64"
  elif [[ $(arch) =~ ("aarch64"|"arm64") ]]; then get_arch="arm64"
  else echo_content red "  [!] Only amd64/arm64 supported"; exit 1
  fi
  echo -e "  [\xE2\x9C\x93] Architecture: ${get_arch}"
}

install_depend() {
  echo "  [*] Installing system dependencies..."
  if [[ "${package_manager}" == apt-get || "${package_manager}" == apt ]]; then
    ${package_manager} update -y -qq
  fi
  ${package_manager} install -y -q curl systemd nftables jq sqlite3 openssl 2>/dev/null || true
  echo -e "  [\xE2\x9C\x93] Dependencies installed"
}

get_installed_version() {
  if [[ -x /usr/local/honest-ui/honest-ui ]]; then
    /usr/local/honest-ui/honest-ui -v 2>/dev/null | sed -n 's/.*version \([^\ ]*\).*/\1/p' || echo ""
  fi
}

get_system_info() {
  local os_info arch_info kernel_info mem_info disk_info
  os_info=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
  [[ -z "${os_info}" ]] && os_info="${release^} ${version}"
  arch_info="${get_arch:-$(arch)}"
  kernel_info=$(uname -r)
  mem_info=$(free -m | awk '/^Mem:/{print $2 "MiB"}')
  disk_info=$(df -BG / | awk 'NR==2{print $4}')" free"
  printf "     %-56s \n" "OS     : ${os_info}"
  printf "     %-56s \n" "Arch   : ${arch_info}"
  printf "     %-56s \n" "Kernel : ${kernel_info}"
  printf "     %-56s \n" "Memory : ${mem_info}"
  printf "     %-56s \n" "Disk   : ${disk_info}"
}

# ────────────────────────────────────────────── IP selection ──────────────────────────────────────────────
get_local_ips() {
  ip -4 addr show 2>/dev/null | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1'
}

detect_public_ip() {
  local ip=""
  ip=$(curl -s --max-time 3 https://api.ipify.org 2>/dev/null || echo "")
  [[ -z "${ip}" ]] && ip=$(curl -s --max-time 3 https://ipinfo.io/ip 2>/dev/null || echo "")
  [[ -z "${ip}" ]] && ip=$(curl -s --max-time 3 https://ifconfig.me 2>/dev/null || echo "")
  # validate basic IPv4 format
  if [[ "${ip}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "${ip}"
  fi
}

select_ip_address() {
  echo
  echo "  -- Network Interfaces ----------------------------------------------"

  local ips=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && ips+=("$line")
  done < <(get_local_ips)

  if [[ ${#ips[@]} -eq 0 ]]; then
    echo_content red "  [!] No external IP found (only 127.0.0.1)"
    read -r -p "  Enter your server IP manually: " selected_ip
    [[ -z "${selected_ip}" ]] && selected_ip="127.0.0.1"
    echo -e "  [\xE2\x9C\x93] Selected IP: ${selected_ip}"
    return
  fi

  local idx=1
  for ip in "${ips[@]}"; do
    local iface
    iface=$(ip -4 addr show 2>/dev/null | grep "inet ${ip}" | awk '{print $NF}')
    echo "  [${idx}] ${ip}  (${iface})"
    ((idx++))
  done
  echo "  [${idx}] Manual IP entry"
  echo
  read -r -p "  Select IP address [1-${idx}]: " ip_choice

  if [[ "${ip_choice}" == "${idx}" ]]; then
    read -r -p "  Enter custom IP address: " selected_ip
    [[ -z "${selected_ip}" ]] && selected_ip="${ips[0]}"
  elif [[ "${ip_choice}" =~ ^[0-9]+$ ]] && [[ "${ip_choice}" -ge 1 ]] && [[ "${ip_choice}" -lt "${idx}" ]]; then
    selected_ip="${ips[$((ip_choice-1))]}"
  else
    echo "  [i] Using default: ${ips[0]}"
    selected_ip="${ips[0]}"
  fi
  echo -e "  [\xE2\x9C\x93] Selected IP: ${selected_ip}"
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
  < /dev/urandom tr -dc 'A-Za-z0-9!@#%^&*()_=+-' | head -c "$len"
}

generate_context_path() {
  < /dev/urandom tr -dc 'a-zA-Z0-9' | head -c 19
}

# ────────────────────────────────────────────── DB helpers ────────────────────────────────────────────────
db_set_config() {
  local db="$1" key="$2" val="$3"
  [[ -f "${db}" ]] && command -v sqlite3 &>/dev/null && \
    sqlite3 "${db}" "INSERT OR REPLACE INTO config (key, value) VALUES ('${key}', '${val}')" 2>/dev/null || true
}

db_get_config() {
  local db="$1" key="$2"
  if [[ -f "${db}" ]] && command -v sqlite3 &>/dev/null; then
    sqlite3 "${db}" "SELECT value FROM config WHERE key='${key}'" 2>/dev/null || echo ""
  fi
}

db_get_username() {
  local db="$1"
  if [[ -f "${db}" ]] && command -v sqlite3 &>/dev/null; then
    sqlite3 "${db}" "SELECT username FROM account WHERE id=1" 2>/dev/null || echo ""
  fi
}

# ────────────────────────────────────────────── systemd install ────────────────────────────────────────────
install_h_ui_systemd() {
  detect_system
  install_depend

  if systemctl status honest-ui >/dev/null 2>&1; then
    echo_content red "  [!] Honest-UI is already installed"
    read -r -p "  Press Enter to continue..."
    return
  fi

  echo
  echo -e "\033[1m  ============== Installing Honest-UI ==============\033[0m"

  echo "  [*] Creating data directory..."
  mkdir -p "${HUI_DATA_SYSTEMD}"
  export HUI_DATA="${HUI_DATA_SYSTEMD}"
  sed -i '/^HUI_DATA=/d' /etc/environment 2>/dev/null || true
  echo "HUI_DATA=${HUI_DATA_SYSTEMD}" >> /etc/environment
  echo -e "  [\xE2\x9C\x93] Data directory: ${HUI_DATA_SYSTEMD}"

  select_ip_address

  local rand_port
  rand_port=$(generate_random_port)
  echo
  read -r -p "  Enter web panel port [default: ${rand_port}]: " h_ui_port
  [[ -z "${h_ui_port}" ]] && h_ui_port="${rand_port}"

  read -r -p "  Enter timezone [default: Asia/Tehran]: " h_ui_time_zone
  [[ -z "${h_ui_time_zone}" ]] && h_ui_time_zone="Asia/Tehran"

  echo "  [*] Setting timezone..."
  timedatectl set-timezone "${h_ui_time_zone}" 2>/dev/null || true
  timedatectl set-local-rtc 0 2>/dev/null || true
  echo -e "  [\xE2\x9C\x93] Timezone: ${h_ui_time_zone}"

  echo "  [*] Generating secure credentials..."
  local admin_user admin_pass con_pass ctx_path
  admin_user=$(generate_strong_password 12)
  admin_pass=$(generate_strong_password 20)
  con_pass="${admin_user}.${admin_pass}"
  ctx_path=$(generate_context_path)
  echo -e "  [\xE2\x9C\x93] Credentials generated"

  export GIN_MODE=release

  local bin_url="https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-${get_arch}"
  [[ "latest" != "${hui_systemd_version}" ]] && \
    bin_url="https://github.com/Mr-Javadian/honest-ui/releases/download/${hui_systemd_version}/honest-ui-linux-${get_arch}"

  echo "  [*] Downloading Honest-UI binary..."
  curl -fsSL "${bin_url}" -o /usr/local/honest-ui/honest-ui
  chmod +x /usr/local/honest-ui/honest-ui
  echo -e "  [\xE2\x9C\x93] Binary downloaded"

  echo "  [*] Installing systemd service..."
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
  echo -e "  [\xE2\x9C\x93] Service installed & enabled"

  echo "  [*] First start (initializing database)..."
  systemctl start honest-ui
  sleep 3
  systemctl stop honest-ui
  sleep 1

  local db_path="${HUI_DATA_SYSTEMD}data/h_ui.db"

  echo "  [*] Configuring secure access path..."
  db_set_config "${db_path}" "H_UI_WEB_CONTEXT" "/${ctx_path}"
  echo -e "  [\xE2\x9C\x93] Access path: /${ctx_path}"

  echo "  [*] Setting admin credentials..."
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null && command -v openssl &>/dev/null; then
    local pass_hash
    pass_hash=$(echo -n "${admin_pass}" | openssl dgst -sha224 2>/dev/null | awk '{print $NF}')
    if [[ -n "${pass_hash}" ]]; then
      sqlite3 "${db_path}" "UPDATE account SET username='${admin_user}', pass='${pass_hash}', con_pass='${con_pass}' WHERE id=1" 2>/dev/null || true
      db_set_config "${db_path}" "H_UI_WEB_PORT" "${h_ui_port}"
      db_set_config "${db_path}" "H_UI_IP" "${selected_ip}"
      echo -e "  [\xE2\x9C\x93] Admin credentials configured"
    fi
  else
    echo "  [!] Using default credentials (run 'honest-ui reset' to change)"
  fi

  install_menu_command

  echo "  [*] Starting Honest-UI service..."
  systemctl start honest-ui
  sleep 3

  if systemctl is-active honest-ui >/dev/null 2>&1; then
    echo -e "  [\xE2\x9C\x93] Service started successfully"
  else
    echo "  [!] Service not active, retrying..."
    systemctl restart honest-ui
    sleep 3
    if systemctl is-active honest-ui >/dev/null 2>&1; then
      echo -e "  [\xE2\x9C\x93] Service started on retry"
    else
      echo_content red "  [!] Service failed to start - run: journalctl -u honest-ui -n 50"
    fi
  fi

  echo
  echo -e "\033[1m  ============== Installation Complete ==============\033[0m"
  echo
  echo_content green "  Honest-UI Access URL:      http://${selected_ip}:${h_ui_port}/${ctx_path}"
  echo_content green "  Honest-UI Login Username:  ${admin_user}"
  echo_content green "  Honest-UI Login Password:  ${admin_pass}"
  echo_content green "  Honest-UI Connection Pass: ${con_pass}"
  echo
  echo_content yellow "  [!] Save these credentials in a secure location!"
  echo_content yellow "  To access this menu again, type: honest-ui"
  echo
  read -r -p "  Press Enter to continue..."
}

upgrade_h_ui_systemd() {
  [[ -z "${get_arch}" ]] && detect_system

  if ! systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    echo_content red "  [!] Honest-UI not installed"
    read -r -p "  Press Enter to continue..."
    return
  fi

  local current_version latest_version
  current_version=$(get_installed_version)
  latest_version=$(curl -fsSL "https://api.github.com/repos/Mr-Javadian/honest-ui/releases/latest" | grep '"tag_name":' | sed 's/.*"tag_name": "\(.*\)",.*/\1/')

  echo
  echo "  [i] Current: ${current_version:-unknown}   Latest: ${latest_version:-unknown}"
  [[ "${latest_version}" == "${current_version}" ]] && { echo -e "  [\xE2\x9C\x93] Already up-to-date"; read -r -p "  Press Enter to continue..."; return; }

  echo "  [*] Stopping service..."
  systemctl stop honest-ui 2>/dev/null || true

  echo "  [*] Downloading update..."
  curl -fsSL "https://github.com/Mr-Javadian/honest-ui/releases/latest/download/honest-ui-linux-${get_arch}" -o /usr/local/honest-ui/honest-ui
  chmod +x /usr/local/honest-ui/honest-ui
  echo -e "  [\xE2\x9C\x93] Binary updated"

  echo "  [*] Starting service..."
  systemctl restart honest-ui
  sleep 2
  systemctl is-active honest-ui >/dev/null 2>&1 && echo -e "  [\xE2\x9C\x93] Upgrade successful" || echo_content red "  [!] Service failed to start"
  read -r -p "  Press Enter to continue..."
}

uninstall_h_ui_systemd() {
  if ! systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    echo_content red "  [!] Honest-UI not installed"
    read -r -p "  Press Enter to continue..."
    return
  fi

  echo_content yellow "  ───────────────────────────────────────────────"
  echo_content yellow "  [!] This will COMPLETELY remove Honest-UI:"
  echo "      • Panel binary & systemd service"
  echo "      • Database & all configuration"
  echo "      • All user data & traffic logs"
  echo "      • Port forwarding rules"
  echo_content red "  [!] This action CANNOT be undone!"
  echo_content yellow "  ───────────────────────────────────────────────"
  echo
  read -r -p "  Are you sure? [y/N]: " confirm_uninstall
  [[ "${confirm_uninstall}" != "y" && "${confirm_uninstall}" != "Y" ]] && { echo "  [i] Uninstall cancelled."; read -r -p "  Press Enter to continue..."; return; }

  echo "  [*] Stopping service..." && systemctl stop honest-ui 2>/dev/null || true
  echo "  [*] Disabling & removing service..."
  systemctl disable honest-ui.service 2>/dev/null || true
  rm -f /etc/systemd/system/honest-ui.service
  systemctl daemon-reload && systemctl reset-failed 2>/dev/null || true
  echo "  [*] Removing data..."
  rm -f /usr/local/honest-ui/honest-ui
  rm -rf /usr/local/honest-ui/data
  rm -rf /usr/local/honest-ui/bin
  rm -rf /usr/local/honest-ui/export
  rm -rf /usr/local/honest-ui/logs
  sed -i '/^HUI_DATA=/d' /etc/environment 2>/dev/null || true
  remove_forward
  echo -e "  [\xE2\x9C\x93] Honest-UI uninstalled"
  echo_content yellow "  [!] The 'honest-ui' menu command is still available."
  echo "      To reinstall the panel, run: honest-ui"
  read -r -p "  Press Enter to continue..."
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
  if command -v docker &>/dev/null; then echo -e "  [\xE2\x9C\x93] Docker already installed"; return; fi
  echo "  [*] Installing Docker..."
  bash <(curl -fsSL https://get.docker.com)
  setup_docker_daemon
  systemctl enable docker && systemctl restart docker
  command -v docker &>/dev/null || { echo_content red "  [!] Docker install failed"; exit 1; }
  echo -e "  [\xE2\x9C\x93] Docker installed"
}

install_h_ui_docker() {
  detect_system

  docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q . && { echo_content red "  [!] Honest-UI already installed"; read -r -p "  Press Enter to continue..."; return; }

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

  echo "  [*] Starting Docker container..."
  docker run -d --cap-add=NET_ADMIN --name honest-ui --restart always --network=host \
    -e TZ="${h_ui_time_zone}" \
    -v /honest-ui/bin:/honest-ui/bin -v /honest-ui/data:/honest-ui/data \
    -v /honest-ui/export:/honest-ui/export -v /honest-ui/logs:/honest-ui/logs \
    mr-javadian/honest-ui"${hui_docker_version}" ./honest-ui -p "${h_ui_port}"
  sleep 4

  local db_path="${HUI_DATA_DOCKER}data/h_ui.db"

  echo "  [*] Configuring access path..."
  db_set_config "${db_path}" "H_UI_WEB_CONTEXT" "/${ctx_path}"
  echo -e "  [\xE2\x9C\x93] Access path: /${ctx_path}"

  echo "  [*] Setting admin credentials..."
  if [[ -f "${db_path}" ]] && command -v sqlite3 &>/dev/null && command -v openssl &>/dev/null; then
    local pass_hash
    pass_hash=$(echo -n "${admin_pass}" | openssl dgst -sha224 2>/dev/null | awk '{print $NF}')
    if [[ -n "${pass_hash}" ]]; then
      sqlite3 "${db_path}" "UPDATE account SET username='${admin_user}', pass='${pass_hash}', con_pass='${con_pass}' WHERE id=1" 2>/dev/null || true
      db_set_config "${db_path}" "H_UI_WEB_PORT" "${h_ui_port}"
      db_set_config "${db_path}" "H_UI_IP" "${selected_ip}"
      echo -e "  [\xE2\x9C\x93] Admin credentials configured"
    fi
  fi

  echo "  [*] Restarting container..."
  docker restart honest-ui 2>/dev/null || true
  sleep 2

  echo
  echo -e "\033[1m  ============== Installation Complete ==============\033[0m"
  echo
  echo_content green "  Honest-UI Access URL:      http://${selected_ip}:${h_ui_port}/${ctx_path}"
  echo_content green "  Honest-UI Login Username:  ${admin_user}"
  echo_content green "  Honest-UI Login Password:  ${admin_pass}"
  echo_content green "  Honest-UI Connection Pass: ${con_pass}"
  echo
  echo_content yellow "  [!] Save these credentials in a secure location!"
  echo
  read -r -p "  Press Enter to continue..."
}

upgrade_h_ui_docker() {
  command -v docker &>/dev/null || { echo_content red "  [!] Docker not installed"; read -r -p "  Press Enter to continue..."; return; }
  docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q . || { echo_content red "  [!] Honest-UI not installed"; read -r -p "  Press Enter to continue..."; return; }

  local latest_version current_version
  latest_version=$(curl -fsSL "https://api.github.com/repos/Mr-Javadian/honest-ui/releases/latest" | grep '"tag_name":' | sed 's/.*"tag_name": "\(.*\)",.*/\1/')
  current_version=$(docker exec honest-ui ./honest-ui -v 2>/dev/null | sed -n 's/.*version \([^\ ]*\).*/\1/p')
  echo "  [i] Current: ${current_version:-unknown}   Latest: ${latest_version:-unknown}"
  [[ "${latest_version}" == "${current_version}" ]] && { echo -e "  [\xE2\x9C\x93] Already up-to-date"; read -r -p "  Press Enter to continue..."; return; }

  echo "  [*] Removing old container..." && docker rm -f honest-ui && docker rmi mr-javadian/honest-ui 2>/dev/null || true
  echo "  [*] Deploying new version..."
  docker run -d --cap-add=NET_ADMIN --name honest-ui --restart always --network=host \
    -e TZ="${h_ui_time_zone}" \
    -v /honest-ui/bin:/honest-ui/bin -v /honest-ui/data:/honest-ui/data \
    -v /honest-ui/export:/honest-ui/export -v /honest-ui/logs:/honest-ui/logs \
    mr-javadian/honest-ui ./honest-ui -p "${h_ui_port}"
  sleep 2
  echo -e "  [\xE2\x9C\x93] Upgrade successful"
  read -r -p "  Press Enter to continue..."
}

uninstall_h_ui_docker() {
  command -v docker &>/dev/null || { echo_content red "  [!] Docker not installed"; read -r -p "  Press Enter to continue..."; return; }
  docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q . || { echo_content red "  [!] Honest-UI not installed"; read -r -p "  Press Enter to continue..."; return; }

  echo_content yellow "  ───────────────────────────────────────────────"
  echo_content yellow "  [!] This will COMPLETELY remove Honest-UI:"
  echo "      • Docker container & image"
  echo "      • Database & all configuration"
  echo "      • All user data & traffic logs"
  echo "      • Port forwarding rules"
  echo_content red "  [!] This action CANNOT be undone!"
  echo_content yellow "  ───────────────────────────────────────────────"
  echo
  read -r -p "  Are you sure? [y/N]: " confirm_uninstall
  [[ "${confirm_uninstall}" != "y" && "${confirm_uninstall}" != "Y" ]] && { echo "  [i] Uninstall cancelled."; read -r -p "  Press Enter to continue..."; return; }

  echo "  [*] Removing container..." && docker rm -f honest-ui
  echo "  [*] Removing image..." && docker images mr-javadian/honest-ui -q | xargs -r docker rmi -f
  echo "  [*] Removing data..." && rm -rf /honest-ui/
  remove_forward
  echo -e "  [\xE2\x9C\x93] Uninstall complete"
  read -r -p "  Press Enter to continue..."
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
  local current_port="" db_path=""

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    db_path="${HUI_DATA_SYSTEMD}data/h_ui.db"
    current_port=$(db_get_config "${db_path}" "H_UI_WEB_PORT")
    [[ -z "${current_port}" ]] && current_port=$(grep -oP '(?<=-p )\d+' /etc/systemd/system/honest-ui.service 2>/dev/null || echo "8081")
  elif command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    db_path="${HUI_DATA_DOCKER}data/h_ui.db"
    current_port=$(db_get_config "${db_path}" "H_UI_WEB_PORT")
    [[ -z "${current_port}" ]] && current_port="8081"
  else
    echo_content red "  [!] Honest-UI not installed"; read -r -p "  Press Enter to continue..."; return
  fi

  echo "  [i] Current port: ${current_port}"
  read -r -p "  Enter new port [1-65535]: " new_port
  [[ -z "${new_port}" ]] && { echo "  [i] No change"; read -r -p "  Press Enter to continue..."; return; }
  [[ ! "${new_port}" =~ ^[0-9]+$ || "${new_port}" -lt 1 || "${new_port}" -gt 65535 ]] && { echo_content red "  [!] Invalid port"; return; }

  if ss -tlnp 2>/dev/null | grep -q ":${new_port} "; then
    echo "  [!] Port ${new_port} is in use"
    read -r -p "  Continue? [y/N]: " ans; [[ "${ans}" != "y" && "${ans}" != "Y" ]] && { read -r -p "  Press Enter to continue..."; return; }
  fi

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    echo "  [*] Updating systemd service..."
    sed -i "s|-p [0-9]*|-p ${new_port}|" /etc/systemd/system/honest-ui.service
    systemctl daemon-reload && systemctl restart honest-ui
    echo -e "  [\xE2\x9C\x93] Port changed"
  fi

  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    echo "  [*] Recreating Docker container..."
    docker rm -f honest-ui
    docker run -d --cap-add=NET_ADMIN --name honest-ui --restart always --network=host \
      -e TZ="${h_ui_time_zone}" \
      -v /honest-ui/bin:/honest-ui/bin -v /honest-ui/data:/honest-ui/data \
      -v /honest-ui/export:/honest-ui/export -v /honest-ui/logs:/honest-ui/logs \
      mr-javadian/honest-ui ./honest-ui -p "${new_port}"
    echo -e "  [\xE2\x9C\x93] Docker port changed"
  fi

  db_set_config "${db_path}" "H_UI_WEB_PORT" "${new_port}"

  echo -e "  [\xE2\x9C\x93] Port updated to ${new_port}"
  read -r -p "  Press Enter to continue..."
}

reset_sysadmin() {
  local found_reset=false

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    found_reset=true
  fi
  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    found_reset=true
  fi

  ${found_reset} || { echo_content red "  [!] Honest-UI not installed"; read -r -p "  Press Enter to continue..."; return; }

  echo_content yellow "  ───────────────────────────────────────────────"
  echo_content yellow "  [!] This will reset the admin password:"
  echo "      • A new random password will be generated"
  echo "      • The current password will stop working"
  echo "      • All other data remains intact"
  echo_content yellow "  ───────────────────────────────────────────────"
  echo
  read -r -p "  Are you sure? [y/N]: " confirm_reset
  [[ "${confirm_reset}" != "y" && "${confirm_reset}" != "Y" ]] && { echo "  [i] Reset cancelled."; read -r -p "  Press Enter to continue..."; return; }

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    export HUI_DATA="${HUI_DATA_SYSTEMD}"
    echo "  [*] Resetting (systemd)..."
    /usr/local/honest-ui/honest-ui reset
    systemctl restart honest-ui
  fi
  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    echo "  [*] Resetting (Docker)..."
    docker exec honest-ui ./honest-ui reset
    docker restart honest-ui 2>/dev/null || true
  fi
  read -r -p "  Press Enter to continue..."
}

view_status() {
  echo
  local found=false

  if systemctl list-units --type=service --all 2>/dev/null | grep -q 'honest-ui.service'; then
    found=true
    echo "  +- systemd ----------------------------------------------------------+"
    local status
    status=$(systemctl is-active honest-ui 2>/dev/null || echo "inactive")
    printf "  |  %-57s |\n" "Status:   ${status^}"
    printf "  +-------------------------------------------------------------------+"
    echo

    local db_path="${HUI_DATA_SYSTEMD}data/h_ui.db"
    local port_val ctx_val user_val ip_val
    port_val=$(db_get_config "${db_path}" "H_UI_WEB_PORT")
    ctx_val=$(db_get_config "${db_path}" "H_UI_WEB_CONTEXT")
    user_val=$(db_get_username "${db_path}")
    ip_val=$(db_get_config "${db_path}" "H_UI_IP")

    # Auto-detect IP if not saved
    [[ -z "${ip_val}" ]] && ip_val=$(get_local_ips | head -1)
    # Fall back to public IP detection
    [[ -z "${ip_val}" ]] && ip_val=$(detect_public_ip)
    [[ -z "${ip_val}" ]] && ip_val="your-server-ip"

    port_val="${port_val:-15360}"
    ctx_val="${ctx_val:-/}"
    user_val="${user_val:-sysadmin}"

    printf "  |  %-57s |\n" "Port:     ${port_val}"
    printf "  |  %-57s |\n" "Path:     ${ctx_val}"
    printf "  |  %-57s |\n" "Username: ${user_val}"
    printf "  |  %-57s |\n" "Access:   http://${ip_val}:${port_val}${ctx_val}"
    printf "  +-------------------------------------------------------------------+"
    echo
    systemctl status honest-ui --no-pager -l 2>&1 | head -6
    echo
  fi

  if command -v docker &>/dev/null && docker ps -a -q -f "name=^honest-ui$" 2>/dev/null | grep -q .; then
    found=true
    echo "  +- Docker ------------------------------------------------------------+"
    local status
    status=$(docker inspect honest-ui --format '{{.State.Status}}' 2>/dev/null || echo "not found")
    printf "  |  %-57s |\n" "Status:   ${status^}"
    printf "  +-------------------------------------------------------------------+"
    echo

    local db_path="${HUI_DATA_DOCKER}data/h_ui.db"
    local port_val ctx_val user_val ip_val
    port_val=$(db_get_config "${db_path}" "H_UI_WEB_PORT")
    ctx_val=$(db_get_config "${db_path}" "H_UI_WEB_CONTEXT")
    user_val=$(db_get_username "${db_path}")
    ip_val=$(db_get_config "${db_path}" "H_UI_IP")

    [[ -z "${ip_val}" ]] && ip_val=$(get_local_ips | head -1)
    [[ -z "${ip_val}" ]] && ip_val=$(detect_public_ip)
    [[ -z "${ip_val}" ]] && ip_val="your-server-ip"

    port_val="${port_val:-15360}"
    ctx_val="${ctx_val:-/}"
    user_val="${user_val:-sysadmin}"

    printf "  |  %-57s |\n" "Port:     ${port_val}"
    printf "  |  %-57s |\n" "Path:     ${ctx_val}"
    printf "  |  %-57s |\n" "Username: ${user_val}"
    printf "  |  %-57s |\n" "Access:   http://${ip_val}:${port_val}${ctx_val}"
    printf "  +-------------------------------------------------------------------+"
    echo
  fi

  ${found} || echo_content yellow "  Honest-UI is not installed"
  echo
  read -r -p "  Press Enter to continue..."
}

ssh_local_port_forwarding() {
  read -r -p "  SSH forwarding port [default: 8082]: " fwd_port && [[ -z "${fwd_port}" ]] && fwd_port="8082"
  read -r -p "  Honest-UI port [default: 8081]: " ui_port && [[ -z "${ui_port}" ]] && ui_port="8081"
  ssh -N -f -L 0.0.0.0:"${fwd_port}":localhost:"${ui_port}" localhost
  echo -e "  [\xE2\x9C\x93] Forwarding 0.0.0.0:${fwd_port} -> localhost:${ui_port}"
  read -r -p "  Press Enter to continue..."
}

install_menu_command() {
  cp "$0" /usr/local/honest-ui/honest-ui-menu.sh 2>/dev/null || \
    curl -fsSL "https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh" -o /usr/local/honest-ui/honest-ui-menu.sh
  chmod +x /usr/local/honest-ui/honest-ui-menu.sh
  ln -sf /usr/local/honest-ui/honest-ui-menu.sh /usr/local/bin/honest-ui
  echo -e "  [\xE2\x9C\x93] Menu command installed: type 'honest-ui'"
}

# ────────────────────────────────────────────── Main ───────────────────────────────────────────────────────
main() {
  cd "$HOME" || exit 0
  init_var

  set +e
  mkdir -p /usr/local/honest-ui
  if [[ -f "$0" ]] && [[ "$0" != */bash ]] && [[ "$0" != */sh ]]; then
    cp "$0" /usr/local/honest-ui/honest-ui-menu.sh
  else
    curl -fsSL "https://raw.githubusercontent.com/Mr-Javadian/honest-ui/main/install.sh" -o /usr/local/honest-ui/honest-ui-menu.sh
  fi
  chmod +x /usr/local/honest-ui/honest-ui-menu.sh
  ln -sf /usr/local/honest-ui/honest-ui-menu.sh /usr/local/bin/honest-ui
  set -e

  while :; do
    clear
    local panel_ver
    panel_ver=$(get_installed_version)

    # Banner
    local cyan="\033[36m"
    local reset="\033[0m"
    echo -e "${cyan}"
    echo '  ╔═══════════════════════════════════════════════════╗'
    echo '  ║                                                   ║'
    echo '  ║   ██╗  ██╗ ██████╗ ███╗   ██╗███████╗███████╗████████╗'
    echo '  ║   ██║  ██║██╔═══██╗████╗  ██║██╔════╝██╔════╝╚══██╔══╝'
    echo '  ║   ███████║██║   ██║██╔██╗ ██║█████╗  ███████╗   ██║   '
    echo '  ║   ██╔══██║██║   ██║██║╚██╗██║██╔══╝  ╚════██║   ██║   '
    echo '  ║   ██║  ██║╚██████╔╝██║ ╚████║███████╗███████║   ██║   '
    echo '  ║   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝   ╚═╝   '
    echo '  ║                                                   ║'
    echo '  ║        Hysteria 2 Management Panel                ║'
    printf "  ║  %-55s║\n" "Script ${hui_script_version}"
    [[ -n "${panel_ver}" ]] && printf "  ║  %-55s║\n" "Panel ${panel_ver}"
    echo '  ╚═══════════════════════════════════════════════════╝'
    echo -e "${reset}"
    echo

    # System Info
    echo -e "${cyan}"
    echo '  ╔═══════════════════════════════════════════════════╗'
    get_system_info
    echo '  ╚═══════════════════════════════════════════════════╝'
    echo -e "${reset}"
    echo

    # Menu
    echo "  Welcome to Honest-UI Installer"
    echo
    echo "  [1]  Install Panel - (systemd)"
    echo "  [2]  Upgrade Panel - (systemd)"
    echo "  [3]  Uninstall - Remove completely (systemd)"
    echo "  ---------------------------------------------------"
    echo "  [4]  Install Panel - (Docker)"
    echo "  [5]  Upgrade Panel - (Docker)"
    echo "  [6]  Uninstall - Remove completely (Docker)"
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
      0) echo "  Goodbye!"; exit 0 ;;
      *) echo_content red "  [!] Invalid option 0-9"; sleep 1.5 ;;
    esac
  done
}

main
