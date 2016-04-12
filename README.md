# yang-cc 

YANG model-driven application core composer

`ycc` is the command line utility providing *gcc-style* schema
composition/compilation.

It provides a useful abstraction on top of
[yang-js](http://github.com/saintkepha/yang-js) for dealing with
schema file(s) in the local filesystem and generating `composition`
schema output which provides **portable** YANG *multi-schema*
snapshots.

  [![NPM Version][npm-image]][npm-url]
  [![NPM Downloads][downloads-image]][downloads-url]

The core composer utilizes a new YANG language extension called
`composition` which contains one or more `specification` and `module`
extensions.  The new `composition` extension is used to represent a
multi-schema YANG module dependencies along with `specification`
extensions capturing base64 encoded `value` that contains
implementation code snippets.  Also, another new YANG language
extension called `link` is introduced which allows any dynamically
discovered/resolved implementation code to be embedded into the
generated `composition` output.

These new YANG language extensions are defined in
[yang-composition.yang](./yang-composition.yang) schema and
implemented in [yang-composition.yaml](./yang-composition.yaml)
specification. It basically generates **portable** compiled output
which contains one or more schema(s) and specification(s). The
generated output can then be sent across the wire and *loaded* by
another instance of the `Composer` to re-create the identical instance
of the core.

This software is brought to you by
[Corenova](http://www.corenova.com).  We'd love to hear your feedback.
Please feel free to reach me at <peter@corenova.com> anytime with
questions, suggestions, etc.

## Installation
```bash
$ npm install -g yang-cc
```
You must have `node >= 0.10.28` as a minimum requirement to use
`yang-cc`.

## Usage
```bash
Usage: ycc [options] file...

Options:
  -I, --include [dir...]  Add directory to compiler search path
  -L, --link [dir...]     Add directory to linker search path
  -o, --output <file>     Place output into <file>
```

Using the provided `ycc` utility produces a *core composition* output
which can then be loaded and placed into runtime by an engine such as
[yang-forge](https://github.com/corenova/yang-forge).  It can also be
loaded by `yang-cc` composer instance as well to restore back to the
original `Core`.

Any *relative* paths specified in -I or -L is resolved using
`process.cwd()` where the `ycc` command is being executed.

## API

Here's an example for using this module:

```js
var ycc = require('yang-cc');
var core = 
  ycc
    .set({ basedir: __dirname })
    .include('./some-local-dir')
    .link('./other-local-dir')
    .load('foo.yang','bar.yang');

console.log(core.dump());
```

### load (file/schema...)

This is the **primary** method for passing in various *filenames* as
well as schema object/string to the `Composer` for producing a newly
compiled `Core` containing one or more *schemas* and *specifications*
along with their **dependencies**.

The ability to dynamically discover **dependencies** from the local
filesystem search path is one of the key capabilities provided by the
`yang-cc` module over the
[yang-js](https://github.com/saintkepha/yang-js).

By referencing various `include` directories prior to issuing the
`load` method, any *include* and *import* statements found within
the schema(s) being composed will be dynamically located and if found,
compiled and bundled as part of the resulting `Core`.

For example, the `yang-cc` module itself *includes* the
[standard](./standard) directory, which contains a handful of common
YANG schema assets:

name | description | reference
--- | --- | ---
[complex-types](standard/complex-types.yang) | extensions to model complex types and typed instance identifiers | RFC-6095
[iana-crypt-hash](standard/iana-crypt-hash.yang) | typedef for storing passwords using a hash function | RFC-7317
[ietf-inet-types](standard/ietf-inet-types.yang) | collection of generally useful types for Internet addresses | RFC-6991
[ietf-yang-types](standard/ietf-yang-types.yang) | collection of generally useful derived data types | RFC-6991

This is purely a convenience reference so that such assets do not need
to be present inside the project directory where new YANG schemas are
being composed.

This call returns a new Core instance.

### include (dir...)

This call registers existing local directories into internal
[search-path](https://github.com/saintkepha/search-path) for dynamic
resolution for schemas and specifications. If supplied as a *relative*
path, it will be prepended with the specified `basedir` property.  If
`basedir` is undefined, it will default to using `process.cwd()`.  It
will *always* use `basedir` as the first directory when attempting to
locate the file(s) whether additional `include()` directories have
been registered or not.

It will dynamically attempt to resolve files passed in without
extensions to look for *.yaml*, *.yml*, and *.yang* files with that
same name.

This call returns the current Composer instance for call chaining
purposes.

### link (dir...)

This call similarly registers existing local directories as in the
`include` case above but it is used for dynamic resolutions for
*features* and *rpcs*.  It is utilized internally while compiling a
schema in order to locate handler functions for the declared `feature`
and `rpc` statements.

It will dynamically attempt to resolve the feature/rpc names inside
the registered linker directories by looking for *.js* and *.coffee*
files.

Here's an example (coffeescript):
```coffeescript
ycc = require 'yang-cc'
core = ycc
  .link './lib'
  .load 'foo.yang', 'bar.yang'
```

If `foo.yang` schema contains references to `feature example { ... }`
and `rpc create { ... }`, then during schema compilation, the
`Composer` will attempt to look for following files:

- ./foo/feature/example.js
- ./foo/feature/example.coffee
- ./lib/foo/feature/example.js
- ./lib/foo/feature/example.coffee
- ./foo/rpc/create.js
- ./foo/rpc/create.coffee
- ./lib/foo/rpc/create.js
- ./lib/foo/rpc/create.coffee

Please note that it automatically *prepends* `<module name>/<type>` when
attempting to locate the handler function file.  This is to ensure
that discovered assets are *namespace* protected when associated
during respective schema compilation.

This call returns the current Composer instance for call chaining
purposes.

### use / resolve

The `Composer` provides similar `use/resolve` capabilities *inherited*
from the underlying [yang-js](https://github.com/saintkepha/yang-js)
parser/compiler module.  The key differences are that the `use` also
performs *filename* resolution by searching the `includes` directories
and that the `resolve` attempts to dynamically resolve missing
definitions from the local filesystem.

### compile / preprocess / parse / ...

The `yang-cc` module extends the
[yang-js](https://github.com/saintkepha/yang-js) parser/compiler
module.  In turn, it *inherits* all methods available from the super
class.

For additional details on other methods available on this module,
please check the documentation found inside the
[yang-js](https://github.com/saintkepha/yang-js) parser/compiler
project.

## Core

TBD - need to write documentation on how to interact with the
generated Core instance.

## License
  [Apache 2.0](LICENSE)

[npm-image]: https://img.shields.io/npm/v/yang-cc.svg
[npm-url]: https://npmjs.org/package/yang-cc
[downloads-image]: https://img.shields.io/npm/dm/yang-cc.svg
[downloads-url]: https://npmjs.org/package/yang-cc
