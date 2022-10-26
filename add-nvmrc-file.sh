#!/usr/bin/env sh
# Add a .nvmrc file to the current directory.
echo "Adding .nvmrc file..."

# get node version string, or use default "lts/gallium"
NODE_V=${1:-"lts/gallium"}

# write file
echo "-> Writing file"
echo $NODE_V > .nvmrc

# create git commit
git add .nvmrc
git commit -m "chore: add only-allow" --quiet &> /dev/null

echo "...done!"
