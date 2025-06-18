#!/usr/bin/env bash

# =============================================================================
# deploy.sh - Deployment Script for Captive Portal Platform on Raspberry Pi
# =============================================================================
# This script automates the deployment of the Captive Portal Platform
# with Nginx as a reverse proxy on a Raspberry Pi.
#
# Usage: ./deploy.sh [options]
#   Options:
#     --help          Display this help message
#     --update-system Update the system before installation
#     --no-docker     Install without Docker (direct installation)
#     --hostname      Custom hostname for the captive portal (default: captiveportal.local)
#     --port          Custom port for the Flask app (default: 8000)
# =============================================================================

# Strict mode
set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Default configuration
UPDATE_SYSTEM=false
USE_DOCKER=true
HOSTNAME="captiveportal.local"
PORT=8000
NGINX_PORT=80
SECRET_KEY=$(openssl rand -hex 24)
FLASK_ENV="production"
INSTALL_DIR="/opt/captive-portal"
VENV_DIR="/opt/captive-portal/venv"
LOG_DIR="/var/log/captive-portal"
NGINX_CONF="/etc/nginx/sites-available/captive-portal"
SYSTEMD_SERVICE="/etc/systemd/system/captive-portal.service"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Helper Functions
# =============================================================================

print_section() {
    echo -e "\n${BLUE}==============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==============================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_usage() {
    echo "Usage: ./deploy.sh [options]"
    echo "  Options:"
    echo "    --help          Display this help message"
    echo "    --update-system Update the system before installation"
    echo "    --no-docker     Install without Docker (direct installation)"
    echo "    --hostname      Custom hostname for the captive portal (default: captiveportal.local)"
    echo "    --port          Custom port for the Flask app (default: 8000)"
}

# Check if the script is running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root. Please use sudo."
        exit 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# =============================================================================
# Parse Command Line Arguments
# =============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                print_usage
                exit 0
                ;;
            --update-system)
                UPDATE_SYSTEM=true
                shift
                ;;
            --no-docker)
                USE_DOCKER=false
                shift
                ;;
            --hostname)
                HOSTNAME="$2"
                shift 2
                ;;
            --port)
                PORT="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

# =============================================================================
# System Preparation
# =============================================================================

update_system() {
    if [ "$UPDATE_SYSTEM" = true ]; then
        print_section "Updating System"
        apt-get update
        apt-get upgrade -y
        apt-get autoremove -y
        apt-get autoclean -y
        print_success "System updated successfully"
    else
        print_info "Skipping system update"
    fi
}

install_dependencies() {
    print_section "Installing Dependencies"
    
    apt-get update
    apt-get install -y \
        nginx \
        python3 \
        python3-pip \
        python3-venv \
        git \
        curl \
        openssl \
        supervisor

    if [ "$USE_DOCKER" = true ]; then
        # Install Docker if not already installed
        if ! command_exists docker; then
            print_info "Installing Docker..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            usermod -aG docker pi
            rm get-docker.sh
        else
            print_info "Docker already installed"
        fi

        # Install Docker Compose if not already installed
        if ! command_exists docker-compose; then
            print_info "Installing Docker Compose..."
            apt-get install -y docker-compose-plugin
            ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
        else
            print_info "Docker Compose already installed"
        fi
    fi

    print_success "Dependencies installed successfully"
}

# =============================================================================
# Application Installation
# =============================================================================

setup_application_directories() {
    print_section "Setting Up Application Directories"
    
    # Create necessary directories
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$LOG_DIR"
    
    # Set proper permissions
    chown -R pi:pi "$INSTALL_DIR"
    chown -R pi:pi "$LOG_DIR"
    
    print_success "Application directories created"
}

clone_repository() {
    print_section "Cloning Repository"

    # If the repository exists locally, copy it
    if [ -f "$SCRIPT_DIR/wsgi.py" ]; then
        print_info "Copying local repository..."
        rsync -av --exclude='.git' --exclude='venv' --exclude='__pycache__' \
              --exclude='*.pyc' --exclude='deploy.sh' \
              "$SCRIPT_DIR/" "$INSTALL_DIR/"
    else
        # Otherwise, clone from Git (replace with your repository URL)
        print_info "Cloning from Git repository..."
        cd "$INSTALL_DIR"
        git clone https://github.com/brianbirir/captive-portal-platform.git .
    fi
    
    chown -R pi:pi "$INSTALL_DIR"
    print_success "Repository cloned/copied successfully"
}

configure_environment() {
    print_section "Configuring Environment"

    # Create .env file for environment variables
    cat > "$INSTALL_DIR/.env" << EOF
FLASK_APP=wsgi.py
FLASK_ENV=$FLASK_ENV
SECRET_KEY=$SECRET_KEY
PORT=$PORT
EOF

    chown pi:pi "$INSTALL_DIR/.env"
    chmod 600 "$INSTALL_DIR/.env"
    
    print_success "Environment configured"
}

# =============================================================================
# Direct Installation (Non-Docker)
# =============================================================================

direct_installation() {
    print_section "Setting Up Python Environment"
    
    # Create and activate virtual environment
    python3 -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install requirements
    cd "$INSTALL_DIR"
    pip install pipenv
    pipenv install --system --deploy
    
    # Install gunicorn if not in Pipfile
    pip install gunicorn
    
    print_success "Python environment set up and dependencies installed"
    
    # Create .env file
    cat > "$INSTALL_DIR/.env" << EOF
FLASK_APP=wsgi.py
FLASK_ENV=$FLASK_ENV
SECRET_KEY=$SECRET_KEY
DATABASE_URL=sqlite:///captive_portal.db
EOF
    
    # Initialize database
    print_section "Setting Up Database"
    export FLASK_APP=wsgi.py
    flask db init
    flask db migrate -m "Initial migration"
    flask db upgrade
    
    # Create admin user
    python -c "
from app import create_app, db
from app.models import User
app = create_app()
with app.app_context():
    if User.query.filter_by(email='admin@example.com').first() is None:
        admin = User(email='admin@example.com')
        admin.set_password('password')
        db.session.add(admin)
        db.session.commit()
        print('Default admin user created')
    else:
        print('Default admin user already exists')
"
    
    # Create backups directory
    mkdir -p "$INSTALL_DIR/backups"
    
    print_success "Database initialized successfully"
}

create_systemd_service() {
    print_section "Creating Systemd Service"
    
    cat > "$SYSTEMD_SERVICE" << EOF
[Unit]
Description=Captive Portal Platform
After=network.target

[Service]
User=pi
Group=pi
WorkingDirectory=$INSTALL_DIR
EnvironmentFile=$INSTALL_DIR/.env
ExecStart=$VENV_DIR/bin/gunicorn -c gunicorn_config.py wsgi:app
Restart=always
RestartSec=5
StandardOutput=append:$LOG_DIR/captive-portal.log
StandardError=append:$LOG_DIR/captive-portal-error.log

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable captive-portal.service
    systemctl start captive-portal.service
    
    print_success "Systemd service created and started"
}

# =============================================================================
# Docker Installation
# =============================================================================

docker_installation() {
    print_section "Setting Up Docker Environment"
    
    cd "$INSTALL_DIR"
    
    # Create docker-compose.rpi.yml optimized for Raspberry Pi
    cat > docker-compose.rpi.yml << EOF
services:
  web:
    build: 
      context: .
      dockerfile: Dockerfile
    container_name: captive_portal
    restart: always
    ports:
      - "127.0.0.1:$PORT:8000"
    environment:
      - FLASK_APP=wsgi.py
      - FLASK_ENV=$FLASK_ENV
      - SECRET_KEY=$SECRET_KEY
      - DATABASE_URL=sqlite:///captive_portal.db
    volumes:
      - ./app:/app/app
      - ./migrations:/app/migrations
      - ./captive_portal.db:/app/captive_portal.db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
EOF
    
    # Create backups directory
    mkdir -p "$INSTALL_DIR/backups"
    
    # Build and start the Docker container
    docker-compose -f docker-compose.rpi.yml up -d --build
    
    print_success "Docker environment set up and container started"
}

# =============================================================================
# Nginx Configuration
# =============================================================================

configure_nginx() {
    print_section "Configuring Nginx as Reverse Proxy"
    
    # Create Nginx configuration
    cat > "$NGINX_CONF" << EOF
server {
    listen $NGINX_PORT default_server;
    listen [::]:$NGINX_PORT default_server;
    
    server_name $HOSTNAME;
    
    access_log /var/log/nginx/captive-portal-access.log;
    error_log /var/log/nginx/captive-portal-error.log;
    
    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /static/ {
        alias $INSTALL_DIR/app/static/;
        expires 30d;
    }
}
EOF
    
    # Enable the site
    ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/captive-portal
    
    # Test Nginx configuration
    nginx -t
    
    # Restart Nginx
    systemctl restart nginx
    
    print_success "Nginx configured as reverse proxy"
}

# =============================================================================
# Network Configuration
# =============================================================================

configure_network() {
    print_section "Configuring Network"
    
    # Add hostname to /etc/hosts if not already there
    if ! grep -q "$HOSTNAME" /etc/hosts; then
        echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
    fi
    
    # Configure hostname
    hostnamectl set-hostname captive-portal
    
    print_success "Network configured"
}

# =============================================================================
# Finalization and Verification
# =============================================================================

verify_installation() {
    print_section "Verifying Installation"
    
    sleep 5 # Give services time to start
    
    if [ "$USE_DOCKER" = true ]; then
        if docker ps | grep -q captive_portal; then
            print_success "Docker container is running"
        else
            print_error "Docker container is not running"
            docker ps -a
            exit 1
        fi
    else
        if systemctl is-active --quiet captive-portal; then
            print_success "Captive Portal service is running"
        else
            print_error "Captive Portal service is not running"
            systemctl status captive-portal
            exit 1
        fi
    fi
    
    if curl -s http://127.0.0.1:$NGINX_PORT > /dev/null; then
        print_success "Nginx is serving the application"
    else
        print_error "Nginx is not serving the application"
        systemctl status nginx
        exit 1
    fi
    
    print_section "Installation Complete!"
    print_info "Captive Portal is now available at http://$HOSTNAME"
    print_info "If you're accessing remotely, make sure to add an entry in your hosts file:"
    print_info "  <raspberry_pi_ip> $HOSTNAME"
}

# =============================================================================
# Optional: Add Captive Portal Functionality
# =============================================================================

setup_captive_portal() {
    print_section "Setting Up Captive Portal Functionality"
    
    # Install dnsmasq for DNS redirection
    apt-get install -y dnsmasq hostapd
    
    # Configure dnsmasq
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    
    cat > /etc/dnsmasq.conf << EOF
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
domain=local
address=/#/$HOSTNAME
EOF
    
    # Configure hostapd for access point
    cat > /etc/hostapd/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=CaptivePortal
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=password123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
    
    # Enable hostapd
    sed -i 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/' /etc/default/hostapd
    
    # Configure network interfaces
    cat > /etc/network/interfaces.d/wlan0 << EOF
allow-hotplug wlan0
iface wlan0 inet static
    address 192.168.4.1
    netmask 255.255.255.0
    network 192.168.4.0
    broadcast 192.168.4.255
EOF
    
    # Configure IP forwarding
    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    
    # Configure iptables for NAT
    cat > /etc/iptables.ipv4.nat << EOF
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i wlan0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.1:80
-A PREROUTING -i wlan0 -p tcp --dport 443 -j DNAT --to-destination 192.168.4.1:80
-A POSTROUTING -o eth0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i wlan0 -o eth0 -j ACCEPT
COMMIT
EOF
    
    # Create script to load iptables rules at startup
    cat > /etc/network/if-up.d/iptables << EOF
#!/bin/sh
iptables-restore < /etc/iptables.ipv4.nat
EOF
    
    chmod +x /etc/network/if-up.d/iptables
    
    # Enable and start services
    systemctl unmask hostapd
    systemctl enable hostapd
    systemctl enable dnsmasq
    
    print_success "Captive portal functionality set up"
    print_info "Wireless network name: CaptivePortal"
    print_info "Wireless password: password123"
    print_info "You may need to reboot for all changes to take effect"
}

# =============================================================================
# Main Script Execution
# =============================================================================

main() {
    print_section "Starting Captive Portal Platform Deployment on Raspberry Pi"
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check if running as root
    check_root
    
    # Update system if requested
    update_system
    
    # Install dependencies
    install_dependencies
    
    # Set up application directories
    setup_application_directories
    
    # Clone or copy repository
    clone_repository
    
    # Configure environment
    configure_environment
    
    # Install using Docker or directly
    if [ "$USE_DOCKER" = true ]; then
        docker_installation
    else
        direct_installation
        create_systemd_service
    fi
    
    # Configure Nginx
    configure_nginx
    
    # Configure network
    configure_network
    
    # Verify installation
    verify_installation
    
    # Ask if user wants to set up captive portal functionality
    read -p "Do you want to set up captive portal functionality? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_captive_portal
        print_info "Reboot is recommended to apply all changes"
        read -p "Do you want to reboot now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            reboot
        fi
    fi
}

# Execute main function with all args
main "$@"
