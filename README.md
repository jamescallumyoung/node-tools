# node-tools

A collection of tools for bootstrapping, managing, and working with Node.

Made with <3 by [James Young](https://github.com/jamescallumyoung)

## usage

Every script takes it's option as the first arg.

Every script accepts a `--git` flag to automatically add the changed files to git.

e.g.:

```sh
# no args
./add-only-allow.sh

# set the package manager
./add-only-allow.sh npm

# set the package manager, and enable git 
./add-only-allow.sh npm --git
```
