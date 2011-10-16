
r  = require './rondom'
fs = require 'fs'


# Fetch a tuple from the given `table`, where the value of
# `keycol` is the payload of cookie named `key`, on mysql
# connection `client`, and store that as `req.phpsession`.
exports.rawMwSqlSession = ({ key, keycol, table, client }) ->

  q = "select * from #{table} where #{keycol} = ?"

  (req, res, next) ->

#      console.log "on entry:", req.phpsession
    return next() if req.phpsession?
    return next() unless (ssn = req.cookies[key])?

    client.query q, [ssn], (err, [res], fields) ->

      return next err if err?

      req.phpsession = res if res?
      next()

# Fetch the content of file `sess_FOO` in `phpsessiondir`,
# where FOO is the payload of cookie `key`, decode its
# obscure format and stick it in `req.phpsession`.
exports.rawPhpFileSession = ({ key, phpsessiondir }) ->

  fs.readdirSync phpsessiondir

  (req, res, next) ->

#      console.log "on entry:", req.phpsession
    return next() if req.phpsession?
    return next() unless (ssn = req.cookies[key])?

    sessionfile = "#{phpsessiondir}/sess_#{ssn}"

    fs.readFile sessionfile, 'utf8', (err, data) ->

      if not err?
        req.phpsession = parseSessionFile data
        return next()

      switch err.code
        when 'ENOENT'
          next()
        else
          console.warn """when reading session file:
                          #{sessionfile}: #{err.message}"""
          next err

parseSessionFile = (data) ->
  ob = {}
  for line in data.split /;/ when line isnt ''
    [key, raw] = line.split /\|/
    val     = parsePayload raw if raw? and raw.length > 2
    ob[key] = val              if val?
  ob

parsePayload = (raw) ->

  rex = (re, f = r.identity, group = 1) ->
    res = raw.match re
    res[group] if res?

  switch raw[0..1]
    when 'i:' then rex /^i:(\d+)/, Number
    when 's:' then rex /^s:\d+:"(.*)"/
    else raw[2..]



# Sanity: ensure session has the key `id` and that it doesn't
# contain a zero.
checkSession = (req) ->
  s = req.phpsession
  if (not s?) or (not s.id?) or (s.id? is 0)
    delete req.phpsession

# Lots of helpless stuff here.
import_session = (hf) -> (params) ->

  handler = hf params
  
  (req, res, next) ->
    handler req, res, (err) ->
      return next err if err?
#        console.log "s pre:", req.phpsession
      req.phpsession = r.obmap req.phpsession, params.mapping
      checkSession req
#        console.log "s post:", req.phpsession
      next()


exports.mwSqlSession   = import_session exports.rawMwSqlSession

exports.phpFileSession = import_session exports.rawPhpFileSession

