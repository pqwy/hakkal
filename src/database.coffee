
rondom = require './rondom'
mysql  = require 'mysql'

table  = 'calendar_thingie'

module.exports = ({ database, user, password }) ->

  client = mysql.createClient { database, user, password }

  client.on "error", (err) ->
    switch err.code
      when 'ECONNREFUSED'
        console.log "lost database, reconnecting."
      else
        console.log "client error:", err.message

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

