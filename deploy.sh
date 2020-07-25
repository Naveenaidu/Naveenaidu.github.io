#!/bin/bash
hugo -D
git push origin develop
cp -r public/ /tmp/ 
git checkout master 
cp -r /tmp/public/. .
git add .
git commit -m "Build Static website"
rm -r /tmp/public
