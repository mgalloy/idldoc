#!/bin/sh

git submodule update --init --recursive

cd lib/mgcmake; git pull origin master
cd lib; git pull origin master
