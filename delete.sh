#!/bin/bash

# Color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

read -p "Enter the domain name: " domain
echo -e "Verifying domain name: ${GREEN}${domain}${NC}"

read -p "Enter the username: " username
echo -e "Verifying username: ${GREEN}${username}${NC}"
if id "$username" &>/dev/null; then
    echo -e "${RED}Username $username exists${NC}"
    userdel -r "$username" # Delete the user and its home directory
    rm -rf "/home/$domain" # Remove the folders
    echo -e "${GREEN}User $username and associated folders deleted${NC}"
else
    echo -e "${GREEN}Username $username does not exist${NC}"
fi
