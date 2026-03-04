set -e

sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git ufw nginx software-properties-common certbot python3-certbot-nginx

if ! command -v docker &> /dev/null
then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

if ! command -v docker-compose &> /dev/null
then
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

sudo ufw allow 'Nginx Full'
sudo ufw allow 22/tcp
sudo ufw --force enable

echo "Building and starting containers..."
docker-compose up -d --build

echo "Running migrations..."
docker-compose exec -T web python manage.py migrate --noinput
docker-compose exec -T web python manage.py collectstatic --noinput

DOMAIN="hojiyevschool.uz"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

echo "Configuring Nginx..."
sudo tee $NGINX_CONF <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /static/ {
        alias /root/bonum/static/;
    }

    location /media/ {
        alias /root/bonum/media/;
    }
}
EOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

echo "Do you want to setup SSL (HTTPS) with Certbot? (y/n)"
read setup_ssl
if [ "$setup_ssl" == "y" ]; then
    sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN
fi

echo "Deployment complete! Your project should be live at http://$DOMAIN"