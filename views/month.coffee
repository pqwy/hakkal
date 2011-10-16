
@title       = 'Kalendar!'
@stylesheets = ['calendar']
@scripts     = ['zappa/jquery', 'month_template', 'calendar']


div id: 'container', ->

  div id: 'subcontainer', ->

    div id: 'logo'

    h5 ->

      text 'Kalendar za dežurstva &nbsp;|'
      div class: 'strelica', id: 'prev'
      span id: 'monthname'
      div class: 'strelica', id: 'next'
      text '|'

  div class: 'underline'

  div id: 'contents'

