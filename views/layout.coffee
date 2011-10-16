doctype 5
html ->
  head ->
    title @title if @title?
    if @scripts?
      script {src: "#{s}.js"} for s in @scripts
    if @stylesheets?
      link { rel: 'stylesheet', type: "text/css", href: "#{s}.css" } for s in @stylesheets
    if @coffees?
      coffeescript c for c in @coffees
    coffeescript @coffee if @coffee?
  body @body


