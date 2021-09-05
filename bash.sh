#!/bin/bash
docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 600000000
docker run -d --name centos7 pycontribs/centos:7 sleep 600000000
docker run -d --name fedora pycontribs/fedora sleep 600000000
echo 'docker run'
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass 

docker stop ubuntu
docker rm ubuntu
echo 'rm ubuntu'
docker stop fedora
docker rm fedora
echo 'rm fedora'
docker stop centos7
docker rm centos7
echo 'rm centos7'
echo 'end'
