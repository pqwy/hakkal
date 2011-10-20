
window.monthcalendar = ({ contents, prev, next, monthname, yearname, authcheck }) ->

  offset = 0

  $(prev).click(-> offset -= 1; load()) if prev?
  $(next).click(-> offset += 1; load()) if next?

  load = ->

    $.ajax "month/relative/#{offset}",
      success: (data, status) ->

        $(monthname).text data.monthname if monthname?
        $(yearname).text data.year       if yearname?

        $(contents).empty().append templates['calendar-month-template'] data.monthdata

        if authcheck? and authcheck()
          $(contents).find('.available.future, .own.future').click ->

            $.ajax "toggle-ownership/#{@id}",
              type    : 'POST'
              success : load

  load()

