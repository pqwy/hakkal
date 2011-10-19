
port      = 1337

util      = require 'util'
rondom    = require './rondom'
cc        = require './cookiecutter'
database  = require './database'

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

cookiesnatch = (req, res, next) ->
  rondom.logc req.cookies if req.cookies?
  next()

sessionModel = (req, res, next) ->
  req.model = model.forsession req.phpsession
  next()


require('zappa') '127.0.0.1', port, ->


  @configure =>

    @set 'views': "#{__dirname}/../views"

    @enable 'serve jquery'

    @use @express.logger('dev'), 'bodyParser'
    @use 'cookieParser', fileSession, sqlSession, sessionModel
    @use @app.router, @express.static("#{__dirname}/../public")
#      @use require('connect-assets')() ??

  @configure

    development: ->
      @use errorHandler: dumpExceptions: on, showStack: on

    production:  ->
      @user 'errorHandler', 'staticCache'


  @app.param 'offset', (req, res, next, offset) ->
    req.params.offset = o = Number req.params.offset
    req.params.offset = 0 if isNaN o
    next()


  @get '/week/:offset?': ->
    @request.model.weekFromNow @params.offset, (res) => @send res

  @get '/month/:offset?': ->
    @request.model.monthFromNow @params.offset, (res) => @send res

  @post '/toggle/:isoday': ->
    next 'user unknown' if not @request.phpsession?.id?
    @request.model.toggle @params.isoday, => @send ''

  @get '/': ->
    console.log "finally, the foreign session:", @request.phpsession
    @render 'month'

  @coffee '/calendar.js': ->

    $ ->
      offset = 0

      loadCalendar = ->
        $.ajax "month/#{offset}",
          success: (data, status) ->
            console.log data
            $('#monthname').text data.monthname
            $('#yearname').text data.year

            $('#contents').empty()
            $('#contents').append templates.month_template data.monthdata

            $('#contents .available.future, #contents .own.future').click ->
              $.ajax "toggle/#{@id}",
                type    : 'POST'
                success : (data, status) -> loadCalendar()

      $('#prev.strelica').click ->
        offset = offset - 1
        loadCalendar()

      $('#next.strelica').click ->
        offset = offset + 1
        loadCalendar()

      loadCalendar()

