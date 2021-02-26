#!/bin/bash

# config
INSTANCE=/opt/minecraft
ACCOUNT=minecraft
JAR=https://launcher.mojang.com/v1/objects/1b557e7b033b583cd9f66746b7a9ab1ec1673ced/server.jar
TOOL=https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz

# secrets
read -p 'seed: ' seed
read -p 'rcon: ' rcon

# prepare
apt --yes update
apt --yes upgrade
apt --yes install default-jre

# minecraft
mkdir "$INSTANCE"
curl --location "$JAR" --output "$INSTANCE"/server.jar
curl --location "$TOOL" \
	| tar --extract --gzip --directory="$INSTANCE" --strip=1 --wildcards '*/mcrcon'

cp --recursive instance/. "$INSTANCE"/
echo "level-seed=$seed"    >> "$INSTANCE"/server.properties
echo "rcon.password=$rcon" >> "$INSTANCE"/server.properties
echo "MCRCON_PASS=$rcon"   >> "$INSTANCE"/service.conf

# account
groupadd "$ACCOUNT"
useradd --system --home-dir "$INSTANCE" --gid "$ACCOUNT" "$ACCOUNT"
chown -R "$ACCOUNT":"$ACCOUNT" "$INSTANCE"

# service
cp minecraft.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft
