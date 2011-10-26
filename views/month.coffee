
@title       = 'Kalendar!'
@stylesheets = ['calendar']
@scripts     = ['zappa/jquery', 'calendar', 'calendar-month-template']
@metas       = [sponsored: 'yup']  if @authenticated
@coffee      = ->

  $ -> monthcalendar

        contents  : '#contents'
        prev      : '#prev.strelica', next      : '#next.strelica'
        monthname : '#monthname'    , yearname  : '#yearname'
        onhold    : '#on-hold'

        authcheck : -> $('meta[sponsored]').length isnt 0

div id: 'container', ->

  div id: 'subcontainer', ->

    a href: '/', -> div id: 'logo'

    h5 id: 'title', ->

      text 'Kalendar za dežurstva &nbsp;|'
      div class: 'strelica', id: 'prev'
      span id: 'monthname'; text '&nbsp;'; span id: 'yearname'; text '.'
      div class: 'strelica', id: 'next'
      text '|'

    text '&nbsp;&nbsp;'
    if @authenticated
      div class: 'loggedin', @name
    else
      a href: 'https://wiki.razmjenavjestina.org/index.php?title=Special:UserLogin', ->
        div class: 'notloggedin', 'anonymous'

  div class: 'underline'

  div id: 'contents'

  div id: 'on-hold', style: 'display: none', '...'

