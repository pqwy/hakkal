
inject = (stuff, mapper) -> mapper item for item in stuff if stuff?

doctype 5

html ->
  head ->
    title @title if @title?

    inject @metas, meta

    inject @scripts, (s) ->
      script src: if /^http/.test s then s else "#{s}.js"

    inject @stylesheets, (s) ->
      link rel: 'stylesheet', type: "text/css", href: "#{s}.css"

    inject @coffees, coffeescript

    coffeescript @coffee if @coffee?

  body @body


