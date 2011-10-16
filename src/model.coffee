
rondom = require './rondom'

daynames   = ['ned', 'pon', 'uto', 'sri', 'čet', 'pet', 'sub']

monthnames = [ 'Siječanj' , 'Veljača'  , 'Ožujak'  , 'Travanj'
             , 'Svibanj'  , 'Lipanj'   , 'Srpanj'  , 'Kolovoz'
             , 'Rujan'    , 'Listopad' , 'Studeni' , 'Prosinac' ]

dayrep = (date) ->
  pad = (x) -> if x < 10 then "0#{x}" else "#{x}"

  year    : pad date.getFullYear()
  month   : pad date.getMonth() + 1
  day     : pad date.getDate()
  dayname : daynames[date.getDay()]

dateDayString = (date) ->
  { year, month, day } = dayrep date
  "#{year}-#{month}-#{day}"

normalizedDay = (date0) ->
  date = new Date date0
  date[setter](0) for setter in ['setHours', 'setMinutes', 'setSeconds']
  date
  
normalizedToday = -> normalizedDay new Date

# All the days of a week containing this date.
weekdays = (date0) ->

  date = new Date date0
  # Rewind to last Sun
  date.setDate date.getDate() - date.getDay()

  for _ in [0..6]
    date.setDate date.getDate() + 1
    new Date date

# Day-of-week, starting with _monday_.
saneWeekDay = (date) ->
  wd = date.getDay()
  if wd == 0 then 6 else wd - 1

# This-or-last monday.
firstMonday = (date0) ->
  date = new Date date0
  date.setDate date.getDate() - saneWeekDay date
  date


# A monday for each week overlapping this month.
monthdays = (date0) ->

  [month, year] = [date0.getMonth(), date0.getYear()]

  date = new Date date0
  # Rewind to y-m-01.
  date.setDate 1
  # Then, rewind to the mon starting the week containing the 1st.
  date = firstMonday date

  while ( date.getYear() < year or
            date.getMonth() <= month and date.getYear() is year )

    day = new Date date
    date.setDate date.getDate() + 7
    day


# No error-handling form of query: JUST THROW IT.
query = (client, query, params, next) ->
  client.query query, params, (err, res) ->
    if err? then throw err else next res

resolveday = (client, userid, date, next) ->

  q = """
    select c.calendar_day, u.user_id, u.user_name, u.user_real_name
    from calendar_thingie as c
    left join user as u on c.calendar_user = u.user_id
    where c.calendar_day = ?
  """

  rep = dateDayString date

  query client, q, [rep], ([res]) ->
    r = day: dayrep date

    if res?
      r.user   = res.user_name
      r.name   = res.user_real_name
      r.status = if res.user_id == userid then 'own' else 'taken'
    else
      r.status = 'available'

    if date.getDay() in [0, 6] then r.status = 'blocked'
    # 'unimportant' ?

    next r

resolveweek = (client, userid, reference, next) ->
  aux = (day, k) -> resolveday client, userid, day, k
  rondom.collectk1 aux, (weekdays reference), next

resolvemonth = (client, userid, reference, next) ->
  aux = (wrep, k) -> resolveweek client, userid, wrep, k
  rondom.collectk1 aux, (monthdays reference), next

module.exports = (client) ->

  forsession = (ssn) ->

    userid = ssn?.id

    weekFromNow = (offset, next) ->

      reference = normalizedToday()
      reference.setDate reference.getDate() + offset * 7

      resolveweek client, userid, reference, next

    monthFromNow = (offset, next) ->

      reference = normalizedToday()
      reference.setMonth reference.getMonth() + offset

      resolvemonth client, userid, reference, (monthdata) ->
        next { monthdata, monthname: monthnames[reference.getMonth()] }


    { weekFromNow, monthFromNow }

  { forsession }

