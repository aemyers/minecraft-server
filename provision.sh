#!/bin/bash

# environment
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

# account
groupadd "$ACCOUNT"
useradd --system --home-dir "$INSTANCE" --gid "$ACCOUNT" "$ACCOUNT"

# install
mkdir "$INSTANCE"
cp --recursive instance/. "$INSTANCE"/
sed -i "s/{seed}/${seed}/g" "$INSTANCE"/*
sed -i "s/{rcon}/${rcon}/g" "$INSTANCE"/*
curl --location "$JAR" --output "$INSTANCE"/server.jar
curl --location "$TOOL" \
	| tar --extract --gzip --directory="$INSTANCE" --strip=1 --wildcards '*/mcrcon'
chown -R "$ACCOUNT":"$ACCOUNT" "$INSTANCE"

# service
cp systemd.service /etc/systemd/system/minecraft.service
systemctl daemon-reload
systemctl enable minecraft.service
systemctl start minecraft
