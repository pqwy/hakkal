
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


require('zappa') '127.0.0.1', port, ->


  @configure =>

    @set 'views': "#{__dirname}/../views"

    @enable 'serve jquery'

    @use @express.logger('dev'), 'bodyParser'
    @use 'cookieParser', fileSession, sqlSession
    @use @app.router, @express.static("#{__dirname}/../public")
#      @use require('connect-assets')() ??

  @configure

    development: ->
      @use errorHandler: dumpExceptions: on, showStack: on

    production:  ->
      @user 'errorHandler', 'staticCache'


#    @app.param 'offset', (req, res, next, offset) ->
#      console.log "HOOK"
#      o = Number req.params.offset
#      req.params.offset = if o? and not o is NaN then o else 0
#      next()

  dispatchRelative = (meth) ->
    m = model.forsession @request.phpsession
    offset = Number @params.offset ? 0
    m[meth] offset, (result) => @send result

  @get '/week/:offset?': ->
#      m = model.forsession @request.phpsession
#      console.log @params.offset, @request.params.offset
#      m.weekFromNow @params.offset, (r) => @send r
    dispatchRelative.call this, 'weekFromNow'

  @get '/month/:offset?': ->
#      m = model.forsession @request.phpsession
#      m.monthFromNow @params.offset, (r) => @send r
    dispatchRelative.call this, 'monthFromNow'


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
            $('#contents .available.future').click -> alert 'reg'
            $('#contents .own.future').click -> alert 'unreg'

      $('#prev.strelica').click ->
        offset = offset - 1
        loadCalendar()

      $('#next.strelica').click ->
        offset = offset + 1
        loadCalendar()

      loadCalendar()

