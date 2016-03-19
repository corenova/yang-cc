# Composer - wrapper around yang-js to provide gcc-style compilations
#
# composes local file assets into a generated output

yang = require 'yang-js'
Core = require './core'
SearchPath = require './search-path'

class Composer extends yang.Yin

  # it defaults to adopting the 'yang' instance as its origin for
  # symbolic resolution
  constructor: (@origin=yang) ->
    super @origin
    @includes = new SearchPath __dirname, [ 'yaml', 'yml', 'yang' ]
    @links    = new SearchPath __dirname, [ 'js', 'coffee' ]
    if @origin instanceof Composer
      @includes.add @origin.includes...
      @links.add @origin.links...

  # register spec/schema search directories (exists)
  include: ->
    @includes
      .base @resolve 'basedir'
      .add ([].concat arguments...)
    return this

  # register feature search directories (exists)
  link: ->
    @links
      .base @resolve 'basedir'
      .add ([].concat arguments...)
    return this

  # accepts: schema/spec file locations
  # returns: a new Core object
  compose: ->
    @load (@includes.fetch ([].concat arguments...))

  ## OVERRIDES

  # accepts: schema/spec objects and strings
  # returns: a new Core object
  load: ->
    res = (new Composer this).use ([].concat arguments...)
    new Core res

  resolve: (type, key, opts={}) ->
    match = super
    match ?= switch
      when not key?
        @use (@includes.fetch type)...
        super type, key, recurse: false
      when type is 'feature'
        loc = (@links.locate key)[0]
        @set type, key, switch
          when loc? then require loc
          else {}
        super type, key, recurse: false
    return match

module.exports = Composer
