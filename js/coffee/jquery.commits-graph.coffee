$ = window.jQuery


COLOURS = [
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


getColour = (branch) ->
  n = COLOURS.length
  COLOURS[branch % n]

class Graph
  constructor: (@element, @data, options) ->
    defaults =
      height: 800
      width: 200
      y_step: 20
      x_step: 20
      orientation: "vertical"
      dotRadius: 3
      lineWidth: 2

    $container = $(@element)

    x_step = $.extend({}, defaults, options).x_step
    y_step = $.extend({}, defaults, options).y_step
    if options.orientation is "horizontal"
      defaults.width = (@data.length + 2) * x_step
      defaults.height = (branchCount(@data) + 0.5) * y_step
    else
      defaults.width = (branchCount(@data) + 0.5) * x_step
      defaults.height = (@data.length + 2) * y_step

    @options = $.extend({}, defaults, options)

    $container.append @renderGraphCanvas(@data)

  renderGraphCanvas: ->
    canvas = document.createElement("canvas")
    canvas.style.height = @options.height + "px"
    canvas.style.width = @options.width + "px"
    canvas.height = @options.height
    canvas.width = @options.width
    scaleFactor = backingScale()
    if @options.orientation is "horizontal"
      if scaleFactor < 1
        canvas.width = canvas.width * scaleFactor
        canvas.height = canvas.height * scaleFactor
    else
      if scaleFactor > 1
        canvas.width = canvas.width * scaleFactor
        canvas.height = canvas.height * scaleFactor
    @options.scaleFactor = scaleFactor
    
    # draw
    @ctx = canvas.getContext("2d")
    @ctx.lineWidth = @options.lineWidth

    for commit, index in @data
      @renderCommit(index, commit)

    $(canvas)

  renderCommit: (idx, [sha, dot, routes_data]) ->
    [dot_offset, dot_branch] = dot

    # draw dot
    {x_step, y_step, width} = @options
    radius = @options.dotRadius
    if @options.orientation is "horizontal"
      x_hori = width - (idx + 0.5) * x_step
      y_hori = (dot_offset + 1) * y_step
      @ctx.fillStyle = getColour(dot_branch)
      @ctx.beginPath()
      @ctx.arc(x_hori, y_hori, radius , 0, 2 * Math.PI, true)
    else
      x = width - (dot_offset + 1) * x_step
      y = (idx + 0.5) * y_step
      @ctx.fillStyle = getColour(dot_branch)
      @ctx.beginPath()
      @ctx.arc(x, y, radius , 0, 2 * Math.PI, true)
    @ctx.fill()

    # draw route
    for route, index in routes_data
      @renderRoute(idx, route)

  renderRoute: (commit_idx, [from, to, branch]) ->
    {x_step, y_step, width} = @options
    if @options.orientation is "horizontal"
      from_x_hori = width - (commit_idx + 0.5) * x_step
      from_y_hori = (from + 1) * y_step
      to_x_hori = width - (commit_idx + 0.5 + 1) * x_step
      to_y_hori = (to + 1) * y_step
      @ctx.strokeStyle = getColour(branch)
      @ctx.beginPath()
      @ctx.moveTo(from_x_hori, from_y_hori)
      if from_y_hori is to_y_hori
        @ctx.lineTo(to_x_hori, to_y_hori)
      else if from_y_hori > to_y_hori
        @ctx.bezierCurveTo(from_x_hori - x_step / 3 * 2, from_y_hori + y_step / 4, to_x_hori + x_step / 3 * 2, to_y_hori - y_step / 4, to_x_hori, to_y_hori)
      else 
        if from_y_hori < to_y_hori
          @ctx.bezierCurveTo(from_x_hori - x_step / 3 * 2, from_y_hori - y_step / 4, to_x_hori + x_step / 3 * 2, to_y_hori + y_step / 4, to_x_hori, to_y_hori)
    else
      from_x = width - (from + 1) * x_step
      from_y = (commit_idx + 0.5) * y_step
      to_x = width - (to + 1) * x_step
      to_y = (commit_idx + 0.5 + 1) * y_step
      @ctx.strokeStyle = getColour(branch)
      @ctx.beginPath()
      @ctx.moveTo(from_x, from_y)
      if from_x is to_x
        @ctx.lineTo(to_x, to_y)
      else
        @ctx.bezierCurveTo(from_x - x_step / 4, from_y + y_step / 3 * 2, to_x + x_step / 4, to_y - y_step / 3 * 2, to_x, to_y)
    @ctx.stroke()

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
    unless $(this).data("plugin_commits_graph")
      $(this).data("plugin_commits_graph", new Graph(this, $(this).data("graph"), options))

