#!/usr/bin/env bash
set -euo pipefail

if [ "${EUID}" -ne 0 ]; then
  echo "Execute este script com sudo: sudo bash install_docker_ubuntu.sh"
  exit 1
fi

echo "[1/7] Atualizando pacotes..."
apt update

echo "[2/7] Instalando dependencias..."
apt install -y ca-certificates curl

echo "[3/7] Configurando chave oficial da Docker..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "[4/7] Configurando repositorio oficial da Docker..."
cat > /etc/apt/sources.list.d/docker.sources <<EOF2
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF2

apt update

echo "[5/7] Instalando Docker Engine e Docker Compose..."
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[6/7] Habilitando Docker no boot..."
systemctl enable --now docker

echo "[7/7] Validando instalacao..."
docker --version
docker compose version

echo
read -r -p "Deseja adicionar o usuario que chamou o sudo ao grupo docker para usar sem sudo? [s/N]: " resposta
if [[ "${resposta}" =~ ^[SsYy]$ ]]; then
  if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    usermod -aG docker "${SUDO_USER}"
    echo "Usuario ${SUDO_USER} adicionado ao grupo docker. Faca logout/login para aplicar."
  else
    echo "Nao foi possivel identificar o usuario original do sudo."
  fi
fi

echo
echo "Instalacao concluida."
echo "Teste opcional: sudo docker run hello-world"
