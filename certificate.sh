#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print in red
print_error() 
{
    echo -e "${RED}$1${NC}"
}

# Function to print in yellow
print_warning() 
{
    echo -e "${YELLOW}$1${NC}"
}

# Function to print in green
print_success() 
{
    echo -e "${GREEN}$1${NC}"
}

# Function to read user input with a prompt
read_input() 
{
    read -p "$1: " INPUT
    echo "$INPUT"
}

# Validate domain name
validate_domain() 
{
    DOMAIN=$1
    if [[ ! $DOMAIN =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        print_error "Invalid domain name. Please enter a valid domain name."
    fi
}

# Ask for domain name
while true; do
    DOMAIN=$(read_input "Enter your domain name")
    validate_domain "$DOMAIN" && break
done

# Validate document root path
validate_document_root() 
{
    DOCUMENT_ROOT=$1
    if [[ ! -d $DOCUMENT_ROOT ]]; then
        print_error "Invalid document root path. Please enter a valid path."
    fi
}

# Ask for document root path
while true; do
    DOCUMENT_ROOT=$(read_input "Enter the document root path for your domain")
    validate_document_root "$DOCUMENT_ROOT" && break
done

# Ask if "www" should be added to the domain
read -p "Do you want to add 'www' to your domain? (y/n): " ADD_WWW

if [[ $ADD_WWW == "y" ]]; then
  sudo certbot certonly --webroot -v --cert-name $DOMAIN --domains $DOMAIN --domains www.$DOMAIN --agree-tos --no-eff-email --email admin@$DOMAIN --hsts --uir --webroot-path $DOCUMENT_ROOT --rsa-key-size 2048 --non-interactive --preferred-challenges http
  print_success "Certificate obtained successfully!"
elif [[ $ADD_WWW == "n" ]]; then
  sudo certbot certonly --webroot -v --cert-name $DOMAIN --domains $DOMAIN --agree-tos --no-eff-email --email admin@$DOMAIN --hsts --uir --webroot-path $DOCUMENT_ROOT --rsa-key-size 2048 --non-interactive --preferred-challenges http
  print_success "Certificate obtained successfully!"
else
  print_error "Error executing certbot command. Please check your inputs and try again."
fi

