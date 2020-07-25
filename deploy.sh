#!/bin/bash
hugo -D
cp -r public/ /tmp/ 
git checkout master 
cp -r /tmp/public/. .
git add .
git commit -m "Build Static website"
rm -r /tmp/public
git push origin master
git checkout develop
