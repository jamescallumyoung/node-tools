#!/usr/bin/env sh

# initialize a new project (or re-initialize one) using Yarn >= v3 (a.k.a Berry).

# vars
NODE_LTS_V_NAME="lts/hydrogen"  # alias for the latest lts version
NODE_LTS_MINIMUM="18.0.0"       # minimum version in the latest lts range

# step zero: git init
git init

# step one: node
echo $NODE_LTS_V_NAME > .nvmrc
nvm use
git add .nvmrc
git commit -m "chore: add .nvmrc"

# step two: yarn
yarn init -2
git add .editorconfig .gitignore .yarnrc.yml README.md package.json yarn.lock .yarn/releases

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
git add .yarn/releases

yarn install
git add .pnp.cjs yarn.lock

yarn plugin import typescript
git add .yarnrc.yml .yarn/plugins

echo "/.yarn/releases/** binary
      /.yarn/plugins/** binary" > .gitattributes
git add .gitattributes

git commit -m "chore: yarn init modern"

# step three: set minimum versions
npm pkg set "engines.node"=">=$NODE_LTS_MINIMUM"
npm pkg set "engines.npm"="dont-use-npm"
npm pkg set "engines.yarn"=">=$(yarn -v)"
git add package.json
git commit -m "chore: set node engine versions"

# step four: add only-allow
npm pkg set "scripts.preinstall"="npx only-allow yarn"
git add package.json
git commit -m "chore: add only-allow"

# step five: typescript
yarn add -D typescript
git add .pnp.cjs .yarn/cache package.json yarn.lock

yarn run tsc --init
echo '{
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
git add tsconfig.json

npm pkg set "scripts.build"="tsc"
npm pkg set "exports.§.import"="./dist/esm/main.js"
npm pkg set "exports.§.types"="./dist/types/main.d.ts"
sed 's/§/\./g' package.json
git add package.json

mkdir src
echo "console.log(0)" > ./src/main.ts
git add ./src

git commit -m "chore: typescript init"

# step six: add commonjs build
echo '{
        "compilerOptions": {
          "target": "ES2019",
          "module": "CommonJS",
          "outDir": "./dist/cjs"
        },
        "extends": "./tsconfig.json"
      }' > tsconfig-cjs.json
git add tsconfig-cjs.json

npm pkg set "scripts.build-esm"="tsc -p ./tsconfig.json"
npm pkg set "scripts.build-cjs"="tsc -p ./tsconfig-cjs.json"
npm pkg set "scripts.build-cjs"="yarn run build-esm && yarn run build-cjs"
git add package.json
git commit -m "chore: add typescript cjs config"
