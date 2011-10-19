
$ ->
  offset = 0

  loadCalendar = ->
    $.ajax "month/#{offset}",
      success: (data, status) ->
        console.log data
        $('#monthname').text data.monthname
        $('#yearname').text data.year

        $('#contents').empty()
        $('#contents').append templates['calendar-month-template'] data.monthdata

        $('#contents .available.future, #contents .own.future').click ->
          $.ajax "toggle/#{@id}",
            type    : 'POST'
            success : (data, status) -> loadCalendar()

  $('#prev.strelica').click ->
    offset = offset - 1
    loadCalendar()

  $('#next.strelica').click ->
    offset = offset + 1
    loadCalendar()

  loadCalendar()

