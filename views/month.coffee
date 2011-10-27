
@title       = 'Kalendar!'
@stylesheets = ['calendar']
@scripts     = [ 'zappa/jquery', 'socket.io/socket.io', 'zappa/zappa'
               , 'calendar', 'calendar-month-template'
               ]
@metas       = [sponsored: 'yup']  if @authenticated
@coffee      = ->

  $ -> monthcalendar

        contents  : '#contents'
        monthname : '#monthname'
        prev      : '#prev.strelica', next : '#next.strelica'

        authcheck : -> $('meta[sponsored]').length isnt 0

div id: 'container', ->

  div id: 'subcontainer', ->

    a href: '/', -> div id: 'logo'

    h5 id: 'title', ->

      text 'Kalendar dežurstava |'
      div class: 'strelica', id: 'prev'
      span id: 'monthname'
      div class: 'strelica', id: 'next'
      text '|'

    text '&nbsp'
    if @authenticated
      div class: 'loggedin', @name
    else
      a href: '/index.php?title=Special:UserLogin', ->
        div class: 'notloggedin', 'anonymous'

  div class: 'underline'

  div id: 'contents'

