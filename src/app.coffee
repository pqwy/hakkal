
port      = 1337

util      = require 'util'
rondom    = require './rondom'
cc        = require './cookiecutter'
database  = require './database'
client    = require './client'

db = database
      database : 'wiki'
      user     : 'wiki'
      password : 'stonogA1.'

model     = require('./model') db


fileSession = cc.phpFileSession
                phpsessiondir : '/var/lib/php5'
                key           : 'wiki_session'
                mapping       :
                    id   : 'wsUserID'
                    name : 'wsUserName'

sqlSession = cc.mwSqlSession
                key     : 'wikitoken'
                table   : 'user'
                keycol  : 'user_token'
                client  : db
                mapping :
                    id   : 'user_id'
                    name : 'user_name'


session2model = (req, res, next) ->
  req.model = model.forsession req.phpsession
  next()


require('zappa') '127.0.0.1', port, ->

  @configure =>

    @set 'views': "#{__dirname}/../views"

    @enable 'serve jquery'

    @use @express.logger('dev'), 'bodyParser'
    @use 'cookieParser', fileSession, sqlSession, session2model
    @use @app.router 
#      @use require('connect-assets')()
    @use @express.static("#{__dirname}/../public")

  @configure

    development: ->
      @use errorHandler: dumpExceptions: on, showStack: on

    production:  ->
      @user 'errorHandler', 'staticCache'
      @enable 'minify'


  @get '/': ->
    @request.model.userName (name) => @render
      'month':
        authenticated : @request.phpsession?.id?
        name          : name

  @get '/week/relative/:offset': ->
    @request.model.weekFromNow @params.offset, (res) => @send res

  @get '/month/relative/:offset': ->
    @request.model.monthFromNow @params.offset, (res) => @send res

  @post '/toggle-ownership/:isoday': ->
    @authenticated =>
      @request.model.toggle @params.isoday, (res) => @send res

  @client '/calendar.js': client.fullcalendar


  @app.param 'offset', (req, res, next, offset) ->
    if isNaN (req.params.offset = Number req.params.offset)
      req.params.offset = 0
    next()

  @helper authenticated: (f) ->
    if not @request.phpsession?
      @response.writeHead 401, 'content-type': 'text/plain'
      @response.end 'Not authenticated...\n'
    else f()

