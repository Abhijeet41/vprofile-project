#!/bin/bash

# Update package list and install necessary packages
sudo apt update
sudo apt install openjdk-8-jdk wget -y

# Create necessary directories
sudo mkdir -p /opt/nexus/
sudo mkdir -p /tmp/nexus/

# Navigate to temporary directory
cd /tmp/nexus/

# Download Nexus
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz

# Pause to ensure download is complete
sleep 10

# Extract the Nexus archive
EXTOUT=$(tar xzvf nexus.tar.gz)

# Get the extracted directory name
NEXUSDIR=$(echo $EXTOUT | cut -d '/' -f1)

# Pause for a moment
sleep 5

# Remove the tar.gz file
rm -rf /tmp/nexus/nexus.tar.gz

# Copy Nexus files to /opt/nexus
sudo cp -r /tmp/nexus/* /opt/nexus/

# Pause to ensure files are copied
sleep 5

# Create a new user for Nexus
sudo adduser --system --no-create-home --group nexus

# Change ownership of the Nexus files
sudo chown -R nexus:nexus /opt/nexus 

# Create the systemd service file for Nexus
sudo bash -c "cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT"

# Configure Nexus to run as the nexus user
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Reload systemd, start Nexus, and enable it to start on boot
sudo systemctl daemon-reload
sudo systemctl start nexus
sudo systemctl enable nexus
