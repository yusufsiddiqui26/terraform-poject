#!/bin/bash
sudo yum update -y && \
sudo yum install docker -y && \
sudo systemctl start docker && \
sudo usermod -aG docker ec2-user
docker run -d -p 8080:80 --name=nginx nginx