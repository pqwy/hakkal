
# client-side view

month = this

for week in month

  div class: 'subcontainer', ->
    ul ->

      for d in week
        li ->

          [outer, inner, info] =
            switch d.status
              when 'taken'     then [d.status    , 'info'   , d.name]
              when 'own'       then ['taken.own' , 'info'   , d.name]
              when 'blocked'   then [d.status    , 'noway'  , ''    ]
              when 'available' then [d.status    , 'action' , ''    ]

          spec = "##{d.day.year}-#{d.day.month}-#{d.day.day}"
          spec = spec + ".#{outer}"
          spec = spec + '.future'      if d.future?
          spec = spec + '.current'     if d.today?
          spec =        '.unimportant' if d.distant?

          div spec, ->

            text "#{d.day.day} "
            span class: 'dayname', "| #{d.day.dayname} |"
            text " #{d.user ? ''}"

            (div class: 'noway') if d.status == 'own'

            div class: inner, info

