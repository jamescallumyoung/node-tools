#!/usr/bin/env sh
# Configure the Node versions that can safely run this project.
echo "Setting Node engine version..."

# Set command args
GIT=false # don't commit to git by default
WARN_ONLY=false # error on incorrect engines version by default

# read args
for ARG in $@; do
  case $ARG in
    --git) GIT=true;;
    --warn-only) WARN_ONLY=true;;
  esac;
done

# get node engine version string, or use default
NODE_ENG_V=${1:-">=14"} # version 14 or higher; it's LTS supported (Node has multiple concurrent LTS) and it supports ESM

# write config to package.json
echo "-> Writing config to package.json"
npm pkg set "engines.node"="$NODE_ENG_V"

# N.B.:
# the "engines.*" fields only issue warnings by default.
# to enforce the use of the specified engine version, we need to add a line to ".npmrc"

# (conditionally) add configure the .npmrc file
if ! $WARN_ONLY; then
  echo "-> Writing config to .npmrc file"
  touch .npmrc
  echo "engine-strict=true" >> .npmrc
fi

# (conditionally) create git commit
if $GIT; then
  echo "-> Committing file to Git"
  git add package.json
  git add .npmrc
  git commit -m "chore: set node engine version" --quiet &> /dev/null
fi

echo "...done!"
