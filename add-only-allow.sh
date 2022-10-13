#!/usr/bin/env sh
# Add only-allow to the Node project in the current directory.
echo "Adding only-allow..."

# get package manager name, or use default "npm"
PM_NAME=${1:-"npm"}

# write config to package.json
echo "-> Writing config"
npm pkg set "scripts.preinstall"="npx only-allow $PM_NAME"

# create git commit
git add package.json
git commit -m "chore: add only-allow" --quiet &> /dev/null

echo "...done!"
