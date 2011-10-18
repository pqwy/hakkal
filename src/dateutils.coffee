
daynames   = ['Ned', 'Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub']

Date.dayname  = (ix) -> daynames[ix]
Date::dayname = -> Date.dayname this.getDay()

monthnames = [ 'Siječanj' , 'Veljača'  , 'Ožujak'  , 'Travanj'
             , 'Svibanj'  , 'Lipanj'   , 'Srpanj'  , 'Kolovoz'
             , 'Rujan'    , 'Listopad' , 'Studeni' , 'Prosinac' ]

Date.monthname  = (ix) -> monthnames[ix]
Date::monthname = -> Date.monthname this.getMonth()


Date::mod_copy = (fun) ->
  d = new Date this
  fun d
  d

Date::normalized = ->
  this.mod_copy (d) -> d.setHours 0; d.setMinutes 0; d.setSeconds 0

Date.normalizedToday = -> (new Date).normalized()

Date::add = ({ years, months, days }) ->
  this.mod_copy (d) ->
    d.setFullYear d.getYear()  + years  if years?
    d.setMonth    d.getMonth() + months if months?
    d.setDate     d.getDate()  + days   if days?

Date::getWeekday = ->
  weekday = this.getDay()
  if weekday == 0 then 6 else weekday - 1

Date::dateView = ->
  year  : this.getFullYear()
  month : this.getMonth() + 1
  day   : this.getDate()

Date::toDict = ->

  pad = (x) -> if x < 10 then "0#{x}" else "#{x}"
  { year, month, day } = this.dateView()

  year    : pad year
  month   : pad month
  day     : pad day
  dayname : this.dayname()

Date::localeISODateString = ->
  { year, month, day } = this.dateView()
  "#{year}-#{month}-#{day}"

Date::isSameLocalDay = (other) ->
  [v1, v2] = [this.dateView(), other.dateView()]
  v1.year is v2.year and v1.month is v2.month and v1.day is v2.day

Date::firstInWeek = -> this.add days: - this.getWeekday()

Date::firstInMonth = -> this.add days: 1 - this.getDate()

