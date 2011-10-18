
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

resolveday = (client, userid, date, next) ->

  q = """
    select c.calendar_day, u.user_id, u.user_name, u.user_real_name
    from calendar_thingie as c
    left join user as u on c.calendar_user = u.user_id
    where c.calendar_day = ?
  """

  today = Date.normalizedToday()

  client.query_t q, [ date.localeISODateString() ], ([res]) ->

    r =
      day: date.toDict()

    if res?
      [ r.user, r.name ] = [ res.user_name, res.user_real_name ]
      r.status = if res.user_id == userid then 'own' else 'taken'
    else
      r.status = 'available'

    r.today   = true if date.isSameLocalDay today
    r.distant = true if refmonth? and refmonth isnt date.getMonth()
    r.future  = true if r.today? or date > today

    if date.getWeekday() in [5, 6] then r.status = 'blocked'

    next r

resolveweek = (client, userid, reference, next) ->
  aux = (day, k) -> resolveday client, userid, day, k
  rondom.collectk1 aux, (weekdays reference), next

resolvemonth = (client, userid, reference, next) ->
  aux = (monday, k) -> resolveweek client, userid, monday, k
  rondom.collectk1 aux, (monthdays reference), next

module.exports = (client) ->

  forsession = (ssn) ->

    userid = Number ssn?.id

    weekFromNow = (offset, next) ->

      now       = Date.normalizedToday()
      reference = now.add months: offset

      resolveweek client, userid, reference, next

    monthFromNow = (offset, next) ->

      now       = Date.normalizedToday()
      reference = now.add months: offset

      resolvemonth client, userid, reference, (monthdata) ->
        next
          monthdata : monthdata
          year      : reference.getFullYear()
          monthname : reference.monthname()

    { weekFromNow, monthFromNow }

  { forsession }

