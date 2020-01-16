#!/bin/bash
HOME=~/.electron-gyp node-gyp rebuild --target=3.0.5 --arch=x64 --dist-url=https://atom.io/download/electron
 
 #复制文件到目标module
 rm ./scon/scon.node
 cp ./build/Release/scon.node ./scon/scon.node

 #复制文件到使用到的工程
 rm ../../../Mac/flipper-master/node_modules/scon/*
 cp ./scon/scon.node ../../../Mac/flipper-master/node_modules/scon/scon.node
 cp ./scon/index.js ../../../Mac/flipper-master/node_modules/scon/index.js
 cp ./scon/package.json ../../../Mac/flipper-master/node_modules/scon/package.json

 rm ../../../Mac/flipper-master/static/node_modules/scon/*
 cp ./scon/scon.node ../../../Mac/flipper-master/static/node_modules/scon/scon.node
 cp ./scon/index.js ../../../Mac/flipper-master/static/node_modules/scon/index.js
 cp ./scon/package.json ../../../Mac/flipper-master/static/node_modules/scon/package.json
