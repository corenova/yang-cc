# Composer - wrapper around yang-js to provide gcc-style compilations
#
# composes local file assets into a generated output

yang = require 'yang-js'
SearchPath = require './search-path'

class Composer extends yang.Yin

  # it defaults to adopting the 'yang' instance as its parent for
  # symbol resolution
  constructor: (@parent=yang) ->
    super @parent
    @includes = new SearchPath __dirname, [ 'yaml', 'yml', 'yang' ]
    @links    = new SearchPath __dirname, [ 'js', 'coffee' ]
    if @parent instanceof Composer
      @includes.add @parent.includes...
      @links.add @parent.links...

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

  compose: ->
    @load (@includes.fetch ([].concat arguments...))...

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
