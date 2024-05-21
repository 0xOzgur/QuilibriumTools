#!/bin/bash

service ceremonyclient stop
apt install unzip
cd ~/ceremonyclient/node/.config
mv store storeold
wget https://snapshots.cherryservers.com/quilibrium/store.zip
unzip store.zip
rm store.zip
rm -rf storeold
service ceremonyclient start
