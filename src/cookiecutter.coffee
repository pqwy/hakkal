
rondom = require './rondom'
fs     = require 'fs'


# Fetch a tuple from the given `table`, where the value of
# `keycol` is the payload of cookie named `key`, on mysql
# connection `client`, and store that as `req.phpsession`.
exports.rawMwSqlSession = ({ key, keycol, table, client }) ->

  q = "select * from #{table} where #{keycol} = ?"

  (req, res, next) ->

    return next() unless (ssn = req.cookies[key])?

    client.query_t q, [ssn], ([res]) ->
      req.phpsession = res if res?
      next()

# Fetch the content of file `sess_FOO` in `phpsessiondir`,
# where FOO is the payload of cookie `key`, decode its
# obscure format and stick it in `req.phpsession`.
exports.rawPhpFileSession = ({ key, phpsessiondir }) ->

  fs.readdirSync phpsessiondir

  (req, res, next) ->

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

  rex = (re, f = rondom.identity, group = 1) ->
    res = raw.match re
    res[group] if res?

  switch raw[0..1]
    when 'i:' then rex /^i:(\d+)/, Number
    when 's:' then rex /^s:\d+:"(.*)"/
    else raw[2..]


# Sanity: ensure session has the key `id` and that it doesn't
# contain a zero.
checkSession = (s) -> s?.id? and s?.id isnt 0

# Lots of helpless stuff here.
import_session = (hf) -> (params) ->

  handler = hf params
  
  (req, res, next) ->

    return next() if req.phpsession?.id?

    handler req, res, (err) ->

      return next err if err?

      s = rondom.obmap req.phpsession, params.mapping
      if checkSession s then req.phpsession = s else delete req.phpsession
      next()

exports.mwSqlSession   = import_session exports.rawMwSqlSession

exports.phpFileSession = import_session exports.rawPhpFileSession

