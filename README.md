# yang-cc 

YANG model-driven application core composer

`ycc` is the command line utility providing *gcc-style* schema
composition/compilation.

It provides useful abstraction on top of
[yang-js](http://github.com/saintkepha/yang-js) for dealing with
schema file(s) in the local filesystem.

The core composer produces a new YANG language extension output called
`compose` which contains a `reference` to base64 encoded data with the
generated results.

This software is *sponsored* by [Corenova](http://www.corenova.com).

## Installation
```bash
$ npm install -g yangforge
```

You must have `node >= 0.10.28` as a minimum requirement to run
`yangforge`.

## Usage
```
  Usage: ycc [options] file...

  Options:
    -I, --include [dir...]  Add directory to compiler search path
    -L, --link [dir...]     Add directory to linker search path
    -o, --output <file>     Place output into <file>
```
