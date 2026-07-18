#!/bin/bash


# Update packages

apt update -y


# Install Docker

apt install docker.io -y


# Start Docker

systemctl start docker

systemctl enable docker


# Pull image from Docker Hub

docker pull saivenkat/myapp


# Run container

docker run -d -p 3000:3000 saivenkat/myapp