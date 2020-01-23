#!/bin/bash

cp $1/keystore/* $1/server.key
cp $1/signcerts/* $1/server.crt

echo  "***********copying "$1"/keystore/* <--> "$2"/server.key"
echo  "***********copying "$1"/signcerts/* <--> "$2"/server.crt"