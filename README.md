# yang-cc 

YANG model-driven application core composer

`ycc` is the command line utility providing *gcc-style* schema
composition/compilation.

It provides a useful abstraction on top of
[yang-js](http://github.com/saintkepha/yang-js) for dealing with
schema file(s) in the local filesystem.

The core composer produces a new YANG language extension output called
`composition` which contains a `reference` to base64 encoded data with
the generated results. It basically generates **portable** compiled
output which contains one or more schema(s) and specification(s). The
generated output can then be sent across the wire and *loaded* by
another instance of the `Composer` to re-create the identical instance
of the core.

This software is brought to you by [Corenova](http://www.corenova.com).

## Installation
```bash
$ npm install -g yang-cc
```

You must have `node >= 0.10.28` as a minimum requirement to use
`yang-cc`.

## Usage
```
  Usage: ycc [options] file...

  Options:
    -I, --include [dir...]  Add directory to compiler search path
    -L, --link [dir...]     Add directory to linker search path
    -o, --output <file>     Place output into <file>
```

## License
  [Apache 2.0](LICENSE)
