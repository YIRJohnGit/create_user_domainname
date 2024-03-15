#!/bin/bash

# Function to display colored messages
color_echo() 
{
    case "$1" in
        red)    echo -e "\e[91m$2\e[0m";;
        green)  echo -e "\e[92m$2\e[0m";;
        yellow) echo -e "\e[93m$2\e[0m";;
        *)      echo "$2";;
    esac
}

# Function to create Apache configuration
create_apache_config() 
{
    local domain_name="$1"
    local folder_location="$2"
    local php_version="$3"
    local ssl_config="$4"

    local http_config="$domain_name.conf"
    local https_config="$domain_name-le-ssl.conf"

    if [ -e "$http_config" ]; then
        color_echo "red" "Error: Configuration file for HTTP already exists. Aborting. ($http_config)"
        return 1
    fi

    # HTTP Configuration
    {
        echo "# Virtual Host Configuration for HTTP generated from YIR John Script"
        echo "<VirtualHost *:80>"
        echo "    ServerAdmin admin@$domain_name"
        echo "    ServerName $domain_name"
        echo "    ServerAlias www.$domain_name"
        echo ""
        echo "    DocumentRoot $folder_location/public_html"
        echo "    DirectoryIndex index.htm index.html index.shtml index.php index.phtml"
        echo ""
        echo "    <Directory \"$folder_location/public_html\">"
        echo "        Options Indexes FollowSymLinks"
        echo "        AllowOverride All"
        echo "        Require all granted"
        echo "    </Directory>"
        echo ""
        if [ "$php_confirmation" == "y" ]; then
            echo "    ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:90$php_version$folder_location/public_html/\$1"
        fi
        echo ""
        if [ "$ssl_config" == "y" ]; then
            echo "    Redirect permanent / https://$domain_name/"
        fi

        echo ""
        echo "    ErrorLog $folder_location/logs/error.log"
        echo "    CustomLog $folder_location/logs/access.log combined"
        echo ""
        
        echo "</VirtualHost>"
    } > "$http_config"

    # HTTPS Configuration
    if [ "$ssl_config" == "y" ]; then
    {
        echo "# Virtual Host Configuration for HTTPS generated from YIR John Script"
        echo "<VirtualHost *:443>"
        echo "    ServerAdmin admin@$domain_name"
        echo "    ServerName $domain_name"
        echo "    ServerAlias www.$domain_name"
        echo ""
        echo "    DocumentRoot $folder_location/public_html"
        echo "    DirectoryIndex index.htm index.html index.shtml index.php index.phtml"
        echo ""
        echo "    SSLEngine on"
        echo "    SSLCertificateFile /etc/letsencrypt/live/$domain_name/fullchain.pem"
        echo "    SSLCertificateKeyFile /etc/letsencrypt/live/$domain_name/privkey.pem"
        echo "    SSLCertificateChainFile /etc/letsencrypt/live/$domain_name/chain.pem"
        echo ""
        echo "    <Directory \"$folder_location/public_html\">"
        echo "        Options Indexes FollowSymLinks"
        echo "        AllowOverride All"
        echo "        Require all granted"
        echo "    </Directory>"
        if [ "$php_confirmation" == "y" ]; then
            echo "    ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:90$php_version$folder_location/public_html/\$1"
        fi
        
        echo ""
        echo "    ErrorLog $folder_location/logs/error.log"
        echo "    CustomLog $folder_location/logs/access.log combined"
        echo ""
    
        echo "</VirtualHost>"
    } > "$https_config"
    fi

    color_echo "green" "Apache configuration files created successfully."
}

# Input variables
color_echo "yellow" "...for configuration apache web server with / without PHP"

# Input variables
color_echo "yellow" "Enter the domain name (e.g., api.mydomain.com):"
read domain_name

color_echo "yellow" "Enter the folder location (e.g., /home/apimydomaincom):"
read folder_location

# Check if PHP is required
color_echo "yellow" "Do you need PHP support for this domain? (y/n):"
read php_confirmation

php_version=""
if [ "$php_confirmation" == "y" ]; then
    color_echo "yellow" "Enter the PHP version (e.g., 72 / 74 / 80 / 82):"
    read php_version
fi

# Check if SSL configuration is needed
color_echo "yellow" "Do you need to Generate SSL Configuration? (y/n):"
read ssl_configuration_setup

# Create Apache configuration
create_apache_config "$domain_name" "$folder_location" "$php_version" "$ssl_configuration_setup"

BACKUP_DATE_TIME=$(date +%Y%m%d_%H%M%S_%3N)

color_echo "yellow" "sudo cp /etc/httpd/sites-available/${domain_name}.conf ${BACKUP_DATE_TIME}_${domain_name}.conf"
color_echo "yellow" "sudo cp /etc/httpd/sites-available/${domain_name}-le-ssl.conf ${BACKUP_DATE_TIME}_${domain_name}-le-ssl.conf"

color_echo "yellow" "scp ${domain_name}* /etc/httpd/sites-available/"
color_echo "yellow" "sudo httpd -t"
color_echo "yellow" "sudo systemctl restart httpd"
color_echo "yellow" "sudo systemctl restart php${php_version}-php-fpm"
color_echo "yellow" "sudo systemctl status php${php_version}-php-fpm"

sudo cp /etc/httpd/sites-available/${domain_name}.conf ${BACKUP_DATE_TIME}_${domain_name}.conf
sudo cp /etc/httpd/sites-available/${domain_name}-le-ssl.conf ${BACKUP_DATE_TIME}_${domain_name}-le-ssl.conf
sudo scp ${domain_name}* /etc/httpd/sites-available/
sudo mv ${domain_name}.conf ${BACKUP_DATE_TIME}_${domain_name}.conf
sudo mv ${domain_name}-le-ssl.conf ${BACKUP_DATE_TIME}_${domain_name}-le-ssl.conf

# Check httpd configuration
if sudo httpd -t; then
    color_echo "green" "httpd configuration test successful"
    color_echo "yellow"  "please wait restarting httpd..."
else
    color_echo "red"  "httpd configuration test failed, exiting..."
    exit 1
fi

# Restart httpd
if sudo systemctl restart httpd; then
    color_echo "green"  "httpd restarted successfully"
else
    color_echo "red" "httpd restart failed, exiting..."
    exit 1
fi

if [ "$php_confirmation" == "y" ]; then
    # Restart php-fpm
    if sudo systemctl restart php${php_version}-php-fpm; then
        color_echo "green"  "php-fpm restarted successfully"
    else
        color_echo "red"  "php-fpm restart failed, exiting..."
        exit 1
    fi
fi

if [ "$php_confirmation" == "y" ]; then
    # Check php-fpm status
    if sudo systemctl status php${php_version}-php-fpm; then
        color_echo "green"  "php-fpm status check successful"
    else    
        color_echo "red" "php-fpm status check failed, exiting..."
        exit 1
    fi
fi
