#!/bin/bash

dstDir=$2/admincerts
mkdir -p $dstDir
cp $1/signcerts/* $dstDir

echo  "***********copying "$1"/signcerts/* <--> "$dstDir