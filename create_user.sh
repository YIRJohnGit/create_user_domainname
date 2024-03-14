#!/bin/bash

# Color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# domain="ci4fwapibuild.mnserviceproviders.com"
read -p "Enter the domain name: " domain

echo -e "Verifying domain name: ${GREEN}${domain}${NC}"
if [[ $domain =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+$ ]]; then
    echo -e "${GREEN}Domain name is valid${NC}"
else
    echo -e "${RED}Invalid domain name${NC}"
    exit 1
fi

read -p "Enter the username: " username

echo -e "Verifying username: ${GREEN}${username}${NC}"
if id "$username" &>/dev/null; then
    echo -e "${RED}Username $username already exists${NC}"
    echo -e "${YELLOW}Auto Suggestion of Username $username already exists${NC}"
    first_word=$(echo "$domain" | cut -d'.' -f1)
    random_suffix=$(openssl rand -hex 4)

    username="${first_word}${random_suffix}"
    echo -e "Generated username: ${GREEN}${username}${NC}"
else
    echo -e "${GREEN}Username $username does not exist${NC}"
fi


if id "$username" &>/dev/null; then
    echo -e "${RED}Username $username exists${NC}"
    exit 1
else
    echo -e "${GREEN}Username $username does not exist${NC}"
    mkdir -p "/home/$domain/public_html" "/home/$domain/logs" "/home/$domain/email"
    useradd -d "/home/$domain" -m "$username"
    echo -e "${GREEN}User $username created${NC}"
fi
