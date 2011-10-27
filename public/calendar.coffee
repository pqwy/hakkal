
window.monthcalendar = ({ contents, prev, next, monthname, authcheck }) ->

  offset = 0

  if prev? and next?

    $(prev).add(next).click ->
      offset += if this is $(prev)[0] then -1 else 1

      $(contents).html '<div id="on-hold"><(^_^<)<br/>...</div>'
      load()

  load = ->

    $.ajax "month/relative/#{offset}",
      success: (data, status) ->

        $(monthname).text "#{data.monthname} #{data.year}."

        $(contents).empty().append templates['calendar-month-template'] data.monthdata

        if authcheck? and authcheck()

          $(contents).find('.available.future, .own.future').click ->

            $(this).find('div:first').addClass 'spinalone'

            $.ajax "toggle-ownership/#{@id}",
              type    : 'POST'
              success : load

  load()

