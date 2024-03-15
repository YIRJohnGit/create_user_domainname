#!/bin/bash

# Color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

read -p "Enter the domain name: " domain

echo -e "Verifying domain name: ${GREEN}${domain}${NC}"
if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$ ]]; then
    echo -e "${GREEN}Domain name is valid${NC}"
else
    echo -e "${RED}Invalid domain name${NC}"
    exit 1
fi

read -p "Enter the username (leave empty for default): " username_input
if [[ -z "$username_input" ]]; then
    # Set default username
    first_word=$(echo "$domain" | cut -d'.' -f1)
    username="${first_word}"
    echo -e "${YELLOW}Default username set: ${username}${NC}"
else
    username="$username_input"
fi

echo -e "Verifying username: ${GREEN}${username}${NC}"
if id "$username" &>/dev/null; then
    echo -e "${RED}Username $username already exists${NC}"
    first_word=$(echo "$domain" | cut -d'.' -f1)
    random_suffix=$(openssl rand -hex 4) 
    username="${first_word}${random_suffix}"
    echo -e "${YELLOW}new auto generated username $username ${NC}"
else
    echo -e "${GREEN}Username $username does not exist${NC}"
fi

# Prompt for user creation
read -p "Do you want to create user $username? (Y/N): " create_user_response

# Check user response and proceed accordingly
if [[ "$create_user_response" =~ ^(Y|y|YES|yes|Yes)$ ]]; then
    # Create user with specified username and home directory
    useradd -m -d "/home/$domain" "$username"
    echo -e "${GREEN}User $username created${NC}"

    # Create custom folders for the user
    mkdir -p "/home/$domain/public_html" "/home/$domain/logs" "/home/$domain/email"

    # Create user-specific file
    echo "$username" > "/home/$domain/$username.usr"

    # Create info.php file with PHP info
    echo "<?php
    date_default_timezone_set('Asia/Kolkata');
    echo 'Current date and time is ' . date('Y-m-d H:i:s');
    echo '<hr>';
    phpinfo();
    ?>" > "/home/$domain/public_html/info.php"

    # Create index.html file for the user
    echo "<h1>....Initiated</h1>" > "/home/$domain/public_html/index.html"

    # Set ownership of home directory to the user
    chown -R $username:purtainet "/home/$domain"

    # Change permissions of directories to drwxr-xr-x (755)
    find /home/$domain -type d -exec chmod 755 {} \;
    # Change permissions of files to -rw-r--r-- (644)
    find /home/$domain -type f -exec chmod 644 {} \;

    # Change permissions of logs directories to drwxr-x---
    find /home/$domain/logs -type d -exec chmod 750 {} \;
    # Change permissions of logs files to -rw-r-----
    find /home/$domain/logs -type f -exec chmod 640 {} \;


    echo -e "${GREEN}User $username setup complete${NC}"
else
    echo -e "${YELLOW}User creation cancelled${NC}"
fi
