#!/bin/bash

service ceremonyclient stop
apt install unzip -y
rm -r $HOME/ceremonyclient/node/.config/store && wget -qO- https://snapshots.cherryservers.com/quilibrium/store.zip > /tmp/store.zip && unzip -j -o /tmp/store.zip -d $HOME/ceremonyclient/node/.config/store && rm /tmp/store.zip
service ceremonyclient start