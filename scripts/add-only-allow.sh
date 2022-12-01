#!/usr/bin/env sh
# Add only-allow to the Node project in the current directory.
echo "Adding only-allow..."

# Set command args
GIT=false # don't commit to git by default

# read args
for ARG in $@; do
  case $ARG in
    --git) GIT=true;;
  esac;
done

# get package manager name, or use default "npm"
PM_NAME=${1:-"npm"}

# write config to package.json
echo "-> Writing config"
npm pkg set "scripts.preinstall"="npx only-allow $PM_NAME"

# (conditionally) create git commit
if $GIT; then
  echo "-> Committing file to Git"
  git add package.json
  git commit -m "chore: add only-allow" --quiet &> /dev/null
fi

echo "...done!"
