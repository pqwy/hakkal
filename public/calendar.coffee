
window.monthcalendar = ({ contents, prev, next, monthname, yearname, onhold, authcheck }) ->

  offset = 0

  if prev? and next?

    $(prev).data delta: -1
    $(next).data delta:  1

    toggle = -> $(contents).add(onhold).toggle()
    reload = if not onhold? then load else -> toggle(); load andThen: toggle

    $(prev).add(next).click ->
      offset += $(this).data 'delta'; reload()

  load = ({ andThen: posthook} = {}) ->

    $.ajax "month/relative/#{offset}",
      success: (data, status) ->

        $(monthname).text data.monthname if monthname?
        $(yearname) .text data.year      if yearname?

        $(contents).empty().append templates['calendar-month-template'] data.monthdata

        if authcheck? and authcheck()

          $(contents).find('.available.future, .own.future').click ->

            $(this).find('div:first').addClass 'spinalone'

            $.ajax "toggle-ownership/#{@id}",
              type    : 'POST'
              success : -> load()

        posthook() if posthook?

  load()

