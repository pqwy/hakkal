

window.monthcalendar = ({ contents, prev, next, monthname, yearname }) ->

  offset = 0

  $(prev).click(-> offset -= 1; load()) if prev?
  $(next).click(-> offset += 1; load()) if next?

  load = ->

    $.ajax "month/#{offset}",
      success: (data, status) ->

        $(monthname).text data.monthname if monthname?
        $(yearname).text data.year       if yearname?

        $(contents).empty().append templates['calendar-month-template'] data.monthdata
        $(contents).find('.available.future, .own.future').click ->

          $.ajax "toggle/#{@id}",
            type    : 'POST'
            success : (data, status) -> load()

  load()

