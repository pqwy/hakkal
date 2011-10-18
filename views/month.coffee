
@title       = 'Kalendar!'
@stylesheets = ['calendar']
@scripts     = ['zappa/jquery', 'month_template', 'calendar']


div id: 'container', ->

  div id: 'subcontainer', ->

    div id: 'logo'

    h5 id: 'title', ->

      text 'Kalendar za dežurstva &nbsp;|'
      div class: 'strelica', id: 'prev'
      span id: 'monthname'; text '&nbsp;'; span id: 'yearname'
      div class: 'strelica', id: 'next'
      text '|'

  div class: 'underline'

  div id: 'contents'

