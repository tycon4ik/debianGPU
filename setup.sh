#!/bin/bash

# Script for automatic installation and configuration of XFCE4

echo "Starting installation and configuration..."

# Make the first script executable and run it
echo "Making debins.sh executable and running..."
chmod +x debins.sh
./debins.sh

# Make the second script executable and run it
echo "Making xfce4en.sh executable and running..."
chmod +x xfce4en.sh
./xfce4en.sh

echo "All scripts completed successfully!"
