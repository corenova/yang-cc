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
    @define 'extension', 'specification',
      represent: (arg, obj, opts) -> "specification #{arg};"

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

  dump: (obj, space=2) ->
    switch
      when obj instanceof Core
        super composition: (obj.origin.extract 'specification', 'module'), space
      else super

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
    match ?= switch
      when keys[0] in [ 'module', 'submodule' ]
        @use keys[1]
        super keys..., recurse: false
      when 'feature' is keys[0] and opts.module?
        loc = (@links.resolve [opts.module].concat(keys).join '/')[0]
        @set keys..., switch
          when loc?
            res = require loc
            res.__origin__ = loc
            res
          else
            console.debug? "unable to resolve '#{opts.module}/#{keys.join '/'}'"
            {}
        super keys..., recurse: false
      when 'rpc' is keys[0] and opts.module?
        loc = (@links.resolve [opts.module].concat(keys).join '/')[0]
        # TODO: should 'browserify' require loc and save it in 'specification'
        require loc if loc?
    return match

module.exports = Composer
