$ = window.jQuery

class Route
  constructor: (commit, data, options) ->
    @_data = data
    @commit = commit
    @options = options
    @from = data[0]
    @to = data[1]
    @branch = data[2]

  drawRoute: (ctx) ->
    if @options.orientation is "horizontal"
      from_x_hori = @options.width * @options.scaleFactor - (@commit.idx + 0.5) * @options.x_step * @options.scaleFactor
      from_y_hori = (@from + 1) * @options.y_step * @options.scaleFactor
      to_x_hori = @options.width * @options.scaleFactor - (@commit.idx + 0.5 + 1) * @options.x_step * @options.scaleFactor
      to_y_hori = (@to + 1) * @options.y_step * @options.scaleFactor
      ctx.strokeStyle = @commit.graph.get_color(@branch)
      ctx.beginPath()
      ctx.moveTo from_x_hori, from_y_hori
      if from_y_hori is to_y_hori
        ctx.lineTo to_x_hori, to_y_hori
      else if from_y_hori > to_y_hori
        ctx.bezierCurveTo from_x_hori - @options.x_step * @options.scaleFactor / 3 * 2, from_y_hori + @options.y_step * @options.scaleFactor / 4, to_x_hori + @options.x_step * @options.scaleFactor / 3 * 2, to_y_hori - @options.y_step * @options.scaleFactor / 4, to_x_hori, to_y_hori
      else ctx.bezierCurveTo from_x_hori - @options.x_step * @options.scaleFactor / 3 * 2, from_y_hori - @options.y_step * @options.scaleFactor / 4, to_x_hori + @options.x_step * @options.scaleFactor / 3 * 2, to_y_hori + @options.y_step * @options.scaleFactor / 4, to_x_hori, to_y_hori  if from_y_hori < to_y_hori
    else
      from_x = @options.width * @options.scaleFactor - (@from + 1) * @options.x_step * @options.scaleFactor
      from_y = (@commit.idx + 0.5) * @options.y_step * @options.scaleFactor
      to_x = @options.width * @options.scaleFactor - (@to + 1) * @options.x_step * @options.scaleFactor
      to_y = (@commit.idx + 0.5 + 1) * @options.y_step * @options.scaleFactor
      ctx.strokeStyle = @commit.graph.get_color(@branch)
      ctx.beginPath()
      ctx.moveTo from_x, from_y
      if from_x is to_x
        ctx.lineTo to_x, to_y
      else
        ctx.bezierCurveTo from_x - @options.x_step * @options.scaleFactor / 4, from_y + @options.y_step * @options.scaleFactor / 3 * 2, to_x + @options.x_step * @options.scaleFactor / 4, to_y - @options.y_step * @options.scaleFactor / 3 * 2, to_x, to_y
    ctx.stroke()

class Commit
  constructor: (@graph, @idx, @_data, @options) ->
    @sha = @_data[0]
    @dot = @_data[1]
    @dot_offset = @dot[0]
    @dot_branch = @dot[1]
    @routes = $.map(@_data[2], (e) =>
      new Route(this, e, @options)
    )

  drawDot: (ctx) ->
    radius = @options.dotRadius
    if @options.orientation is "horizontal"
      x_hori = @options.width * @options.scaleFactor - (@idx + 0.5) * @options.x_step * @options.scaleFactor
      y_hori = (@dot_offset + 1) * @options.y_step * @options.scaleFactor
      ctx.fillStyle = @graph.get_color(@dot_branch)
      ctx.beginPath()
      ctx.arc x_hori, y_hori, radius * @options.scaleFactor, 0, 2 * Math.PI, true
    else
      x = @options.width * @options.scaleFactor - (@dot_offset + 1) * @options.x_step * @options.scaleFactor
      y = (@idx + 0.5) * @options.y_step * @options.scaleFactor
      ctx.fillStyle = @graph.get_color(@dot_branch)
      ctx.beginPath()
      ctx.arc x, y, radius * @options.scaleFactor, 0, 2 * Math.PI, true
    ctx.fill()

class GraphCanvas
  constructor: (data, options) ->
    @data = data
    @options = options
    @canvas = document.createElement("canvas")
    @canvas.style.height = options.height + "px"
    @canvas.style.width = options.width + "px"
    @canvas.height = options.height
    @canvas.width = options.width
    scaleFactor = backingScale()
    if @options.orientation is "horizontal"
      if scaleFactor < 1
        @canvas.width = @canvas.width * scaleFactor
        @canvas.height = @canvas.height * scaleFactor
    else
      if scaleFactor > 1
        @canvas.width = @canvas.width * scaleFactor
        @canvas.height = @canvas.height * scaleFactor
    @options.scaleFactor = scaleFactor
    
    @colors = [
      "#e11d21"
      "#fbca04"
      "#009800"
      "#006b75"
      "#207de5"
      "#0052cc"
      "#5319e7"
      "#f7c6c7"
      "#fad8c7"
      "#fef2c0"
      "#bfe5bf"
      "#c7def8"
      "#bfdadc"
      "#bfd4f2"
      "#d4c5f9"
      "#cccccc"
      "#84b6eb"
      "#e6e6e6"
      "#ffffff"
      "#cc317c"
    ]
  toHTML: ->
    @draw()
    $(@canvas)

  get_color: (branch) ->
    n = @colors.length
    @colors[branch % n]

  draw: ->
    ctx = @canvas.getContext("2d")
    ctx.lineWidth = @options.lineWidth
    console.log @data
    n_commits = @data.length
    i = 0

    while i < n_commits
      commit = new Commit(this, i, @data[i], @options)
      commit.drawDot ctx
      j = 0

      while j < commit.routes.length
        route = commit.routes[j]
        route.drawRoute ctx
        j++
      i++

class Graph
  constructor: (element, options) ->
    defaults =
      height: 800
      width: 200
      y_step: 20
      x_step: 20
      orientation: "vertical"
      dotRadius: 3
      lineWidth: 2

    @element = element
    @$container = $(element)
    @data = @$container.data("graph")
    x_step = $.extend({}, defaults, options).x_step
    y_step = $.extend({}, defaults, options).y_step
    if options.orientation is "horizontal"
      defaults.width = (@data.length + 2) * x_step
      defaults.height = (branchCount(@data) + 0.5) * y_step
    else
      defaults.width = (branchCount(@data) + 0.5) * x_step
      defaults.height = (@data.length + 2) * y_step
    @options = $.extend({}, defaults, options)
    @_defaults = defaults
    @applyTemplate()

  # Apply results to HTML template
  applyTemplate: ->
    graphCanvas = new GraphCanvas(@data, @options)
    $canvas = graphCanvas.toHTML()
    $canvas.appendTo @$container

# helpers
branchCount = (data) ->
  maxBranch = -1
  i = 0

  while i < data.length
    j = 0

    while j < data[i][2].length
      if maxBranch < data[i][2][j][0] or maxBranch < data[i][2][j][1]
        maxBranch = Math.max.apply(Math, [
          data[i][2][j][0]
          data[i][2][j][1]
        ])
      j++
    i++
  maxBranch + 1

backingScale = ->
  if window.devicePixelRatio? and window.devicePixelRatio > 1
    window.devicePixelRatio
  else
    1

# jQuery plugin
$.fn.commits = (options) ->
  @each ->
    $(this).data("plugin_commits_graph", new Graph(this, options)) unless $(this).data("plugin_commits_graph")

