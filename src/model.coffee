
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

  { month: month0, year: year0 } = date0.dateView()

  date = (new Date date0).firstInMonth().firstInWeek()

  loop

    { day, month, year } = date.dateView()
    break unless year < year0 or month <= month0 and year is year0

    element = new Date date
    date    = date.add days: 7
    element

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

    r.today   = on if target.isSameLocalDay now
    r.distant = on if refmonth? and refmonth isnt target.getMonth()
    r.future  = on if r.today? or target > now

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

  return next 'Too late.' if target.dateCmp() < now.dateCmp()

  day = target.localeISODateString()

  clearuser = -> client.query_t q2, [userid, day], -> next()
  setuser   = -> client.query_t q3, [userid, day], -> next()

  client.query_t q1, [day], ([res]) ->
    if not res? then setuser()
    else
      { calendar_user } = res
      if calendar_user is userid then clearuser()
      else next 'Not yours.'

resolveUser = (client, userid, next) ->

  q = '''select user_name from user where user_id = ?'''

  client.query_t q, [userid], ([{ user_name }]) -> next user_name

module.exports = (client) ->

  forsession = (ssn) ->

    userid = Number ssn.id if ssn?.id?

    userName = (next) ->
      if userid? then resolveUser client, userid, next else next()

    weekFromNow = (offset, next) ->

      now    = Date.normalizedToday()
      target = now.add months: offset

      resolveweek client, { userid, target, now }, next

    monthFromNow = (offset, next) ->

      now    = Date.normalizedToday()

      # <-- FUGLY, but try setting the month of a date whose
      #     day is 31 and see if it makes ANY FUCKING sense....
      target = new Date now
      target.setDate 1
      target = target.add months: offset

      resolvemonth client, { userid, target, now }, (monthdata) ->
        next
          monthdata     : monthdata
          year          : target.getFullYear()
          monthname     : target.monthname()

    toggle = (isoday, next) ->

      throw Error "session unauth'd" unless userid?

      now    = Date.normalizedToday()
      target = new Date isoday

      return next { ok: off, wat: 'The fuck?' } if isNaN target.getTime()

      toggleuser client, { userid, target, now }, (res) ->
        next if res? then { ok: off, wat: res } else { ok: on }

    { userName, weekFromNow, monthFromNow, toggle }

  { forsession }

