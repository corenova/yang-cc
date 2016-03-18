# search-path - find stuff from local filesystem based on search query

path    = require 'path'
fs      = require 'fs'

class SearchPath extends Array
  constructor: (@basedir, @exts=[]) -> super

  exists: (paths, opts={}) ->
    opts.basedir ?= @basedir
    paths
      .map (f) -> path.resolve opts.basedir, f
      .filter (f) ->
        stat = fs.statSync f
        switch
          when not stat? then false
          when opts.isDirectory then stat.isDirectory()
          when opts.isFile then stat.isFile()
          else false

  # used to specify 'basedir' to use when adding relative paths
  base: (path=@basedir) -> @basedir = path; this

  # TODO: optimize to remove duplicates
  add: (paths...) ->
    @unshift (@exists paths, isDirectory: true)...

  locate: (files...) ->
    files = files.reduce ((a,b) ->
      a.push b
      if !!(path.extname file)
        a.push "#{file}.#{ext}" for ext in @exts
    ), []

    res = []
    @forEach (dir) ->
      res.push (@exists (files.map (f) -> path.resolve dir, f), isFile: true)...
    return res

  fetch: (files...) ->
    (@locate files...).map (f) -> fs.readFileSync f, 'utf-8'

module.exports = SearchPath
