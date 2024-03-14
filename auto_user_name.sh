#!/bin/bash

# Color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

domain="ci4fwapibuild.mnserviceproviders.com"
first_word=$(echo "$domain" | cut -d'.' -f1)
random_suffix=$(openssl rand -hex 4)

username="${first_word}${random_suffix}"

echo -e "Generated username: ${GREEN}${username}${NC}"

if id "$username" &>/dev/null; then
    echo -e "${RED}Username $username exists${NC}"
    exit 1
else
    echo -e "${GREEN}Username $username does not exist${NC}"
    mkdir -p "/home/$domain/public_html" "/home/$domain/logs" "/home/$domain/email"
    useradd -d "/home/$domain" -m "$username"
    echo -e "${GREEN}User $username created${NC}"
fi
