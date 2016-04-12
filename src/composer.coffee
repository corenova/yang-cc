# Composer - wrapper around yang-js to provide gcc-style compilations
#
# composes local file assets into a generated output

yang = require 'yang-js'
Core = require './core'
SearchPath = require 'search-path'

class Composer extends yang.Yin

  # it defaults to adopting the 'yang' instance as its origin for
  # symbolic resolution
  constructor: (origin=yang) ->
    super origin
    @includes = new SearchPath basedir: __dirname, exts: [ 'yaml', 'yml', 'yang' ]
    @links    = new SearchPath basedir: __dirname, exts: [ 'js', 'coffee' ]
    if origin instanceof Composer
      @includes.include origin.includes...
      @links.include origin.links...
    @set basedir: undefined, pattern: /^[\s_-\w\.\/\\]+$/

  # register spec/schema search directories (exists)
  include: ->
    @includes
      .base @resolve 'basedir', warn: false
      .include ([].concat arguments...)
    return this

  # register feature search directories (exists)
  link: ->
    @links
      .base @resolve 'basedir', warn: false
      .include ([].concat arguments...)
    return this

  # accepts: core/schema/spec locations, objects and strings
  # returns: a new Core object
  load: ->
    input = [].concat arguments...
    unless input.length > 0
      throw @error "no input schema(s) to load"
    new Core ((new Composer this).use input)

  dump: (obj, rest...) ->
    ext = @resolve 'extension', 'composition'
    obj = switch
      when not ext? then obj
      when obj instanceof Core
        composition: obj.origin.extract Object.keys(ext.scope)
      else obj
    super obj, rest...

  # process variadic arguments and defines results inside current
  # Composer instance
  #
  # accepts: core/schema/spec locations, objects and strings
  # returns: current Composer instance
  use: ->
    input = ([].concat arguments...).map (x) =>
      if typeof x is 'string' and (@resolve 'pattern').test x
        @includes.fetch x
      else x
    super input...

  # extends resolve to attempt to generate missing symbols
  resolve: (keys..., opts={}) ->
    unless opts instanceof Object
      keys.push opts
      opts = {}
    return unless keys.length > 0

    match = super keys..., warn: false
    match ?= switch keys[0]
      when 'module', 'submodule'
        @use keys[1]
        super keys..., recurse: false

      when 'feature' # global scope (does not get bundled)
        loc = (@links.resolve (keys.join ':'))[0]
        break unless loc?
        require loc

      when 'rpc', 'notification' # module scope (bundled as 'link-action')
        break unless opts.module?
        target = [opts.module].concat(keys).join ':'
        loc = (@links.resolve target)[0]
        if loc?
          try
            res = require loc
            @set @objectify "link-action.#{target}", (resolve, reject) =>
              (browserify loc).bundle (err, buf) =>
                if err? then reject err else resolve (@objectify target, buf)
            res
          catch e then {}
        else
          @resolve "link-action", target, recurse: false
    return match

module.exports = Composer
