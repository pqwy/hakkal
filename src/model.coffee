
rondom = require './rondom'
du     = require './dateutils'


# All the days of a week containing this date.
weekdays = (date0) ->

  date = (new Date date0).firstInWeek()

  for _ in [0..6]
    d    = new Date date
    date = date.add days: 1
    d

# A monday for each week overlapping this month.
monthdays = (date0) ->

  [month, year] = [date0.getMonth(), date0.getYear()]

  date = (new Date date0).firstInMonth().firstInWeek()

  while ( date.getYear() < year or
            date.getMonth() <= month and date.getYear() is year )

    day  = new Date date
    date = date.add days: 7
    day

resolveday = (client, { userid, target, now, refmonth }, next) ->

  q = '''
    select c.calendar_day, u.user_id, u.user_name, u.user_real_name
    from calendar_thingie as c
    left join user as u on c.calendar_user = u.user_id
    where c.calendar_day = ?
  '''

  client.query_t q, [ target.localeISODateString() ], ([res]) ->

    r =
      day: target.toDict()

    if res?
      [ r.user, r.name ] = [ res.user_name, res.user_real_name ]
      r.status = if res.user_id == userid then 'own' else 'taken'
    else
      r.status = 'available'

    r.today   = true if target.isSameLocalDay now
    r.distant = true if refmonth? and refmonth isnt target.getMonth()
    r.future  = true if r.today? or target > now

    if target.getWeekday() in [5, 6] then r.status = 'blocked'

    next r

resolveweek = (client, context, next) ->
  aux = (day, k) ->
    context.target = day
    resolveday client, context, k
  rondom.collectk1 aux, (weekdays context.target), next

resolvemonth = (client, context, next) ->
  context.refmonth = context.target.getMonth()
  aux = (monday, k) ->
    context.target = monday
    resolveweek client, context, k
  rondom.collectk1 aux, (monthdays context.target), next

toggleuser = (client, { userid, target, now }, next) ->

  q1 = '''select calendar_user from calendar_thingie where calendar_day = ?'''
  q2 = '''delete from calendar_thingie
          where calendar_user = ? and calendar_day = ?'''
  q3 = '''insert into calendar_thingie (calendar_user, calendar_day)
          values (?,?)
          on duplicate key update calendar_user = values (calendar_user)'''

  return next 'Too late....' if target < now

  day = target.localeISODateString()

  clearuser = -> client.query_t q2, [userid, day], -> next()
  setuser   = -> client.query_t q3, [userid, day], -> next()


  client.query_t q1, [day], (res) ->
    if not res[0]? then setuser()
    else
      { calendar_user } = res[0]
      if calendar_user is userid then clearuser()
      else next "Taken."

module.exports = (client) ->

  forsession = (ssn) ->

    userid = Number ssn.id if ssn?.id?

    weekFromNow = (offset, next) ->

      now    = Date.normalizedToday()
      target = now.add months: offset

      resolveweek client, { userid, target, now }, (weekdata) ->
        weekdata.authenticated = userid?
        next weekdata

    monthFromNow = (offset, next) ->

      now    = Date.normalizedToday()
      target = now.add months: offset

      resolvemonth client, { userid, target, now }, (monthdata) ->
        next
          monthdata     : monthdata
          year          : target.getFullYear()
          monthname     : target.monthname()
          authenticated : userid?

    toggle = (isoday, next) ->

      throw Error "session unauth'd" unless userid?

      now    = Date.normalizedToday()
      target = new Date isoday

      toggleuser client, { userid, target, now }, next

    { weekFromNow, monthFromNow, toggle }

  { forsession }

