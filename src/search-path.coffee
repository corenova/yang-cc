# search-path - find stuff from local filesystem based on search query

path    = require 'path'
fs      = require 'fs'

class SearchPath extends Array
  constructor: (@basedir, @exts=[]) -> super

  exists: (paths, opts={}) ->
    opts.basedir ?= @basedir
    paths
      .filter (f) -> (typeof f is 'string') and !!f
      .map (f) -> path.resolve opts.basedir, f
      .filter (f) ->
        try stat = fs.statSync f
        catch
        switch
          when not stat? then false
          when opts.isDirectory then stat.isDirectory()
          when opts.isFile then stat.isFile()
          else false

  # used to specify 'basedir' to use when adding relative paths
  base: (path=@basedir) -> @basedir = path; this

  # TODO: optimize to remove duplicates
  add: ->
    @unshift (@exists ([].concat arguments...), isDirectory: true)...

  locate: ->
    files =
      ([].concat arguments...)
        .filter (x) -> x? and !!x
        .reduce ((a,b) =>
          a.push b
          if not !!(path.extname b)
            a.push "#{b}.#{ext}" for ext in @exts
          return a
        ), []
    res = []
    @forEach (dir) =>
      #console.log "checking #{dir} for #{files}"
      res.push (@exists (files.map (f) -> path.resolve dir, f), isFile: true)...
    return res

  fetch: ->
    (@locate ([].concat arguments...)).map (f) -> fs.readFileSync f, 'utf-8'

module.exports = SearchPath
