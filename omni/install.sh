#!/bin/bash

install_curl() {
  echo "🔍 Checking for curl..."
  if ! command -v curl &>/dev/null; then
    echo "⚠️ curl is not installed."

    if [ -f /etc/debian_version ]; then
      echo "📦 Installing curl on Debian/Ubuntu..."
      sudo apt update && sudo apt install -y curl || {
        echo "❌ curl installation failed (apt)."
        exit 1
      }
    elif [ -f /etc/redhat-release ]; then
      echo "📦 Installing curl on RHEL/CentOS..."
      sudo yum install -y curl || {
        echo "❌ curl installation failed (yum)."
        exit 1
      }
    else
      echo "🚫 Unsupported OS. Please install curl manually."
      exit 1
    fi

    command -v curl &>/dev/null && echo "✅ curl installed successfully." || {
      echo "❌ curl still not found after attempted installation."
      exit 1
    }
  else
    echo "✅ curl is already installed."
  fi
}

install_snap() {
  echo "🔍 Checking for Snap..."
  if ! command -v snap &>/dev/null; then
    echo "⚠️ Snap is not installed."

    if [ -f /etc/debian_version ]; then
      echo "📦 Installing Snapd on Debian/Ubuntu..."
      sudo apt update && sudo apt install -y snapd
      sudo systemctl enable --now snapd.socket
      echo "🔁 Rebooting system to finish Snap install..."
      sudo reboot
    else
      echo "🚫 Snap install not supported on this OS. Please install manually."
      exit 1
    fi
  else
    echo "✅ Snap is already installed."
  fi
}

install_certbot() {
  echo "🔍 Checking for Certbot..."
  if ! command -v certbot &>/dev/null; then
    echo "⚙️ Installing Certbot using Snap..."

    sudo snap install core && sudo snap refresh core
    sudo snap install --classic certbot
    sudo snap set certbot trust-plugin-with-root=ok
    sudo snap install certbot-dns-cloudflare

    command -v certbot &>/dev/null && echo "✅ Certbot installed successfully." || {
      echo "❌ Certbot installation failed."
      exit 1
    }
  else
    echo "✅ Certbot is already installed."
  fi
}

install_docker() {
  echo "🔍 Checking for Docker..."

  if ! command -v docker &>/dev/null; then
    echo "⚙️ Docker is not installed. Installing via get.docker.io..."
    curl -fsSL https://get.docker.io | sh

    if [ $? -eq 0 ]; then
      echo "✅ Docker installed successfully."
      sudo usermod -aG docker "$USER"
      echo "👥 Added current user to Docker group (log out and back in to apply)."
    else
      echo "❌ Docker installation failed."
      exit 1
    fi
  else
    echo "✅ Docker is already installed."
  fi
}

request_cert() {
  echo -e "\n🔐 Enter your Cloudflare API Token (input hidden):"
  read -s CF_API_TOKEN
  echo "🔑 Cloudflare API token received."

  CLOUDFLARE_CREDS_FILE=~/creds.ini
  echo "📝 Writing credentials to $CLOUDFLARE_CREDS_FILE..."
  cat <<EOF >"$CLOUDFLARE_CREDS_FILE"
# Cloudflare API token used by Certbot
dns_cloudflare_api_token = $CF_API_TOKEN
EOF
  chmod 600 "$CLOUDFLARE_CREDS_FILE"
  echo "🔒 Credentials saved with secure permissions."

  echo -e "\n🌐 Enter the domain name of Omni (e.g., omni.example.com):"
  read DOMAIN_NAME
  echo "📛 Omni Domain: $DOMAIN_NAME"

  echo "🚀 Requesting certificate for $DOMAIN_NAME..."
  sudo certbot certonly \
    --dns-cloudflare \
    --dns-cloudflare-credentials "$CLOUDFLARE_CREDS_FILE" \
    -d "$DOMAIN_NAME"

  [ $? -eq 0 ] && echo "✅ Certificate obtained for $DOMAIN_NAME." || {
    echo "❌ Failed to obtain certificate."
    exit 1
  }
}

generate_env_file() {
  echo -e "\n🛠 Generating environment configuration..."

  read -p "🌐 Enter your base domain (e.g., example.com): " DOMAIN
  read -p "💻 Enter machine IP (for WireGuard): " MACHINE_IP
  read -p "📧 Enter initial user emails: " INITIAL_EMAILS
  read -p "🔐 Enter Auth0 domain: " AUTH0_DOMAIN
  read -p "🆔 Enter Auth0 client ID: " AUTH0_CLIENT_ID

  UUID=$(uuidgen)
  TEMPLATE_FILE="omni.env.template"
  OUTPUT_FILE="omni.env"

  sed -e "s|<UUID>|$UUID|g" \
    -e "s|<DOMAIN>|$DOMAIN|g" \
    -e "s|<MACHINE_IP>|$MACHINE_IP|g" \
    -e "s|<INIT_EMAIL>|$INITIAL_EMAILS|g" \
    -e "s|<AUTH0_DOMAIN>|$AUTH0_DOMAIN|g" \
    -e "s|<AUTH0_CLIENT_ID>|$AUTH0_CLIENT_ID|g" \
    "$TEMPLATE_FILE" >"$OUTPUT_FILE"

  echo "✅ $OUTPUT_FILE generated successfully."
}

generate_gpg_key() {
  echo "🔐 Generating GPG key..."

  META_UID="Omni (Used for etcd data encryption) <$INITIAL_EMAILS>"
  gpg --batch --pinentry-mode loopback --passphrase '' \
    --quick-generate-key "$META_UID" rsa4096 cert never

  KEY_ID=$(gpg --list-keys --with-colons "$INITIAL_EMAILS" | awk -F: '/^pub/ {print $5; exit}')
  FINGERPRINT=$(gpg --list-secret-keys --with-colons "$INITIAL_EMAILS" | awk -F: '/^fpr:/ {print $10; exit}')

  if [ -z "$KEY_ID" ] || [ -z "$FINGERPRINT" ]; then
    echo "❌ Failed to generate or locate GPG key/fingerprint."
    exit 1
  fi

  echo "➕ Adding encryption subkey..."
  gpg --batch --pinentry-mode loopback --passphrase '' \
    --quick-add-key "$FINGERPRINT" rsa4096 encr never

  echo "📦 Exporting secret key to omni.asc..."
  gpg --armor --output omni.asc --export-secret-key "$INITIAL_EMAILS"
  echo "✅ GPG key generated and exported."
}

start_omni() {
  echo "🚢 Starting Omni using Docker Compose..."
  docker compose --env-file omni.env up -d

  if [ $? -eq 0 ]; then
    echo "✅ Omni is running."
    echo "🔗 Access it at: https://$DOMAIN_NAME"
  else
    echo "❌ Failed to start Omni."
    exit 1
  fi
}

install_curl
install_snap
install_docker
install_certbot
request_cert
generate_env_file
generate_gpg_key
start_omni
