# Composer - wrapper around yang-js to provide gcc-style compilations
#
# composes local file assets into a generated output

yang = require 'yang-js'
SearchPath = require './search-path'

class Composer extends yang.Yin

  # it defaults to adopting the 'yang' instance as its parent for
  # symbol resolution
  constructor: (@parent=yang) ->
    super
    @config =
      basedir: __dirname
    @includes = new SearchPath @config.basedir, [ 'yaml', 'yml', 'yang' ]
    @links    = new SearchPath @config.basedir, [ 'js', 'coffee' ]

  set: (obj={}) -> @config[k] = v for k, v of obj; return this

  # register spec/schema search directories (exists)
  include: -> @includes.base(@config.basedir).add arguments...; return this

  # register feature search directories (exists)
  link: -> @links.base(@config.basedir).add arguments...; return this

  compose: (files...) -> @load (@includes.fetch files...)...

  resolve: (type, key, opts={}) ->
    match = super
    match ?= switch
      when not key? then @use (@includes.fetch type)...; super
      when type is 'feature'
        feature = (@links.locate key)[0]
        require feature if feature?
    return match

module.exports = Composer
