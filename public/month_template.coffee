
month = this

for week in month

  div class: 'subcontainer', ->
    ul ->

      for d in week
        li ->

          [outer, inner, info] = 

            switch d.status

              when 'own','taken' then ['taken','info',d.name]

              when 'blocked'     then [d.status,'noway','']

              when 'available'   then [d.status,'action','']

          div class: outer, ->

            text "#{d.day.day} "
            span class: 'dayname', "| #{d.day.dayname} |"
            text " #{d.user ? ''}"

            (div class: 'noway') if d.status == 'own'

            div class: inner, info

