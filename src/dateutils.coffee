
daynames   = [ 'Ned', 'Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub' ]

Date.dayname  = (ix) -> daynames[ix]
Date::dayname = -> Date.dayname @getDay()

monthnames = [ 'Siječanj' , 'Veljača'  , 'Ožujak'  , 'Travanj'
             , 'Svibanj'  , 'Lipanj'   , 'Srpanj'  , 'Kolovoz'
             , 'Rujan'    , 'Listopad' , 'Studeni' , 'Prosinac' ]

Date.monthname  = (ix) -> monthnames[ix]
Date::monthname = -> Date.monthname @getMonth()


Date::mod_copy = (fun) ->
  d = new Date this
  fun d
  d

Date::normalized = ->
  @mod_copy (d) -> d.setHours 0; d.setMinutes 0; d.setSeconds 0

Date.normalizedToday = -> (new Date).normalized()

Date::add = ({ years, months, days }) ->
  @mod_copy (d) ->
    d.setFullYear d.getFullYearYear() + years  if years?
    d.setMonth    d.getMonth()        + months if months?
    d.setDate     d.getDate()         + days   if days?

Date::getWeekday = ->
  weekday = @getDay()
  if weekday == 0 then 6 else weekday - 1

Date::dateView = ->
  year  : @getFullYear()
  month : @getMonth() + 1
  day   : @getDate()

Date::toDict = ->

  pad = (x) -> if x < 10 then "0#{x}" else "#{x}"
  { year, month, day } = @dateView()

  year  : pad year
  month : pad month
  day   : pad day
  name  : @dayname()

Date::localeISODateString = ->
  { year, month, day } = @dateView()
  "#{year}-#{month}-#{day}"

Date::isSameLocalDay = (other) ->
  [v1, v2] = [@dateView(), other.dateView()]
  v1.year is v2.year and v1.month is v2.month and v1.day is v2.day

Date::firstInWeek = -> @add days: - @getWeekday()

Date::firstInMonth = -> @add days: 1 - @getDate()

