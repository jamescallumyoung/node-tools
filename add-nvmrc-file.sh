#!/usr/bin/env sh
# Add a .nvmrc file to the current directory.
echo "Adding .nvmrc file..."

# Set command args
GIT=false # don't commit to git by default

# read args
for ARG in $@; do
  case $ARG in
    --git) GIT=true;;
  esac;
done

# get node version string, or use default "lts/gallium"
NODE_V=${1:-"lts/gallium"}

# write file
echo "-> Writing file"
echo $NODE_V > .nvmrc

# (conditionally) create git commit
if $GIT; then
  echo "-> Committing file to Git"
  git add .nvmrc
  git commit -m "chore: add only-allow" --quiet &> /dev/null
fi

echo "...done!"
