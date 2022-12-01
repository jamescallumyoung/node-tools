#!/usr/bin/env sh

# initialize a new project (or re-initialize one) using Yarn >= v3 (a.k.a Berry).

# vars
NODE_LTS_V_NAME="lts/hydrogen"  # alias for the latest lts version
NODE_LTS_MINIMUM="18.0.0"       # minimum version in the latest lts range
ENABLE_GIT=false                # bool (true|false); should git be run in each step?

# step zero: git init
$ENABLE_GIT && git init

# step one: node
echo $NODE_LTS_V_NAME > .nvmrc
nvm use
$ENABLE_GIT && git add .nvmrc
$ENABLE_GIT && git commit -m "chore: add .nvmrc"

# step two: yarn
yarn init -2
if ! $ENABLE_GIT ; then
  rm -rf .git
fi
$ENABLE_GIT && git add .editorconfig .gitignore .yarnrc.yml README.md package.json yarn.lock .yarn/releases

# no pnp
#.pnp.*
 #.yarn/*
 #!.yarn/patches
 #!.yarn/plugins
 #!.yarn/releases
 #!.yarn/sdks
 #!.yarn/versions

# pnp
#.yarn/*
 #!.yarn/cache
 #!.yarn/patches
 #!.yarn/plugins
 #!.yarn/releases
 #!.yarn/sdks
 #!.yarn/versions

yarn set version stable
$ENABLE_GIT && git add .yarn/releases

yarn install
$ENABLE_GIT && git add .pnp.cjs yarn.lock

yarn plugin import typescript
$ENABLE_GIT && git add .yarnrc.yml .yarn/plugins

echo \
"/.yarn/releases/** binary
/.yarn/plugins/** binary" > .gitattributes
$ENABLE_GIT && git add .gitattributes

$ENABLE_GIT && git commit -m "chore: yarn init modern"

# step three: set minimum versions
npm pkg set "engines.node"=">=$NODE_LTS_MINIMUM"
npm pkg set "engines.npm"="dont-use-npm"
npm pkg set "engines.yarn"=">=$(yarn -v)"
$ENABLE_GIT && git add package.json
$ENABLE_GIT && git commit -m "chore: set node engine versions"

# step four: add only-allow
npm pkg set "scripts.preinstall"="npx only-allow yarn"
$ENABLE_GIT && git add package.json
$ENABLE_GIT && git commit -m "chore: add only-allow"

# step five: typescript
yarn add -D typescript
$ENABLE_GIT && git add .pnp.cjs .yarn/cache package.json yarn.lock

yarn run tsc --init
echo \
'{
  "compilerOptions": {
    "incremental": true,

    "target": "ES2021",

    "module": "NodeNext",
    "rootDir": "./src",

    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist/esm",
    "declarationDir": "./dist/types",

    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,

    "strict": true,

    "skipLibCheck": true
  },
  "include": [
    "./src/**/*.ts"
  ]
}' > tsconfig.json # overwrite config so there's no comments
$ENABLE_GIT && git add tsconfig.json

npm pkg set "scripts.build"="tsc"
npm pkg set "exports.§.import"="./dist/esm/main.js"
npm pkg set "exports.§.types"="./dist/types/main.d.ts"
sed 's/§/\./g' package.json | tee package.json
$ENABLE_GIT && git add package.json

mkdir src
echo "console.log(0)" > ./src/main.ts
$ENABLE_GIT && git add ./src

$ENABLE_GIT && git commit -m "chore: typescript init"

# step six: add commonjs build
echo \
'{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    "target": "ES2019",
    "module": "CommonJS",
    "outDir": "./dist/cjs"
  }
}' > tsconfig-cjs.json
git add tsconfig-cjs.json

npm pkg set "scripts.build-esm"="yarn run tsc -p ./tsconfig.json"
npm pkg set "scripts.build-cjs"="yarn run tsc -p ./tsconfig-cjs.json"
npm pkg set "scripts.build"="yarn run build-esm && yarn run build-cjs"
npm pkg set "exports.§.require"="./dist/cjs/main.js"
sed 's/§/\./g' package.json | tee package.json
$ENABLE_GIT && git add package.json
$ENABLE_GIT && git commit -m "chore: add typescript cjs config"
