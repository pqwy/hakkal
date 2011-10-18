
util = require 'util'


exports.identity = (x) -> x

exports.obmap = (ob, mapping) ->
  return unless ob?

  r = {}
  if mapping instanceof Array
    r[k1] = ob[k2] for [k1, k2] in mapping when ob[k2]?
  else
    r[k1] = ob[k2] for own k1, k2 of mapping when ob[k2]?
  r

exports.logc = (stuff...) ->
  console.log.apply console,
    (util.inspect s, false, 2, true for s in stuff)

exports.throwK = (k) -> (err, stuff...) ->
  if err? then throw err else k stuff...

# `foldl combine seed . sequence` for the cps monad.
exports.collectk0 = collectk0 = (funs, next, combine, seed) ->

    combine or= (as, a) -> as.push a; as
    seed    or= []

    runner = (idx) ->
      if idx >= funs.length
      	next seed
      else funs[idx] (result) ->
      	seed = combine seed, result
      	runner idx + 1

    runner 0

# `foldl combine seed . sequence . map fun params` for the same monad.
exports.collectk1 = (fun, params, next, combine, seed) ->
  fun0s = ((do (param) -> (h) -> fun param, h) for param in params)
  collectk0 fun0s, next, combine, seed

