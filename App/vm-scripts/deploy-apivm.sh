#!/bin/bash

while getopts "e:m:s:u:" arg; do
	case "${arg}" in
		e) environment=${OPTARG} ;;
        m) mongoServer=${OPTARG} ;;
        s) sasToken=${OPTARG} ;;
		u) storageBaseUrl=${OPTARG} ;;
	esac
done

echo $environment
echo $mongoServer
echo $sasToken
echo $storageBaseUrl

if ! systemctl is-active --quiet nginx 
    then
        cd ~
        curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
        sudo bash nodesource_setup.sh
        sudo apt update 
        sudo apt install -y nginx nodejs build-essential unzip
        sudo npm install pm2@5.1.2 -g

        sudo ufw allow 'Nginx HTTP'

        sudo systemctl stop nginx
        sudo cat <<EOF > ratingapp
server {
    listen 80;
    listen [::]:80;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        #proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        #proxy_set_header Host $host;
        #proxy_cache_bypass $http_upgrade;
    }
}
EOF
        sudo cp ratingapp /etc/nginx/sites-available/ratingapp
        sudo ln -s /etc/nginx/sites-available/ratingapp /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        sudo systemctl start nginx

    else
        echo "Nginx and other stuff already installed.."
fi

if [ $environment != 'test' ] 
    then
        pm2 stop rating-api
        
        if test -d /var/www/api/ 
            then
                sudo rm -fR /var/www/api/
                mkdir /var/www/api/
            else
                echo $USER
        fi

        curl -sL "${storageBaseUrl}/api.zip${sasToken}" -o api.$(date +%Y%m%d%H%M).zip
        unzip api.$(date +%Y%m%d%H%M).zip -d /var/www/api/ 
        chmod 755 -R /var/www/api/
        cd /var/www/api/
        sudo npm install
        
        PORT='3000' MONGODB_URI="mongodb://$mongoServer:27017/webratings" pm2 start /var/www/api/bin/www --name rating-api
        pm2 startup
        pm2 save
    else
        echo "This is test, not executing api stuff..."
fi
