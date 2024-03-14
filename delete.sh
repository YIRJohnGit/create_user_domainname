#!/bin/bash

# Color codes for formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

read -p "Enter the username: " username
echo -e "Verifying username: ${GREEN}${username}${NC}"
if id "$username" &>/dev/null; then
    userdel -r "$username" # Delete the user and its home directory
    echo -e "${GREEN}User $username and associated home directory deleted${NC}"
else
    echo -e "${RED}Username $username does not exist${NC}"
fi
