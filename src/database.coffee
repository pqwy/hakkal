
rondom = require './rondom'
mysql  = require 'mysql'

table  = 'calendar_thingie'

module.exports = ({ database, user, password }) ->

  client = mysql.createClient { user, password }

  client.query "use #{database}"

  client.query """
    create table if not exists #{table} (
      `calendar_day` date not null,
      `calendar_user` int(10) not null,
      primary key (`calendar_day`),
      constraint `fk_calendar_user_id`
      foreign key `fk_calendar_user_id` (`calendar_user`)
      references `user` (`user_id`)
      )
    """

  client.query_t = (as..., k) -> client.query as..., rondom.throwK k

  client


#    user_record = (next) -> (err, [res], fields) ->
#      return next err                     if err?
#      return next Error "User not found." unless res?
#      next null, 
#        id        : res.user_id,        name  : res.user_name,
#        real_name : res.user_real_name, token : res.user_token

#    idsearch   = (userid, next) ->
#      client.query 'select * from user where user_id = ?', [userid],
#        user_record next

#    namesearch = (username, next) ->
#      client.query '''
#        select * from user where
#          lower (user_name) = lower(?)
#        ''', [username], user_record next

#    daysearch = (daystring, next) ->
#      client.query "select * from #{table} where calendar_day = ?", [daystring],
#        (err, [res], fields) ->
#          return next err if err?
#          next null, (res ? {}).calendar_user

#    dayput = (daystring, userid, next) ->
#      client.query """
#          insert into #{table} (calendar_day, calendar_user)
#            values (?, ?)
#            on duplicate key update calendar_user = values (calendar_user)
#          """,
#          [daystring, userid], next

#    client         : client

#    userDataByID   : idsearch
#    userDataByName : namesearch
#    dayInfo        : daysearch
#    daySet         : dayput


module.exports.x = module.exports
                      database : 'wiki'
                      user     : 'wiki'
                      password : 'stonogA1.'

