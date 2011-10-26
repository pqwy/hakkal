
jqui = "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js"

@title       = 'Kalendar!'
@stylesheets = ['calendar']
@scripts     = ['zappa/jquery', 'calendar', 'calendar-month-template']
@coffee      = ->

  $ -> monthcalendar

        contents  : '#contents'
        prev      : '#prev.strelica', next      : '#next.strelica'
        monthname : '#monthname'    , yearname  : '#yearname'
        wait      : '#wait'

        authcheck : -> $('meta[sponsored]').length isnt 0

@metas       = [sponsored: 'yup']  if @authenticated


div id: 'wait', style: 'display: none', '...'

div id: 'container', ->

  div id: 'subcontainer', ->

    div id: 'logo'

    h5 id: 'title', ->

      text 'Kalendar za dežurstva &nbsp;|'
      div class: 'strelica', id: 'prev'
      span id: 'monthname'; text '&nbsp;'; span id: 'yearname'; text '.'
      div class: 'strelica', id: 'next'
      text '|'

  div class: 'underline'

  div id: 'contents'

