React = require 'react'
_ = require 'underscore'

COLOURS = [
  "#e11d21",
  "#fbca04",
  "#009800",
  "#006b75",
  "#207de5",
  "#0052cc",
  "#5319e7",
  "#f7c6c7",
  "#fad8c7",
  "#fef2c0",
  "#bfe5bf",
  "#c7def8",
  "#bfdadc",
  "#bfd4f2",
  "#d4c5f9",
  "#cccccc",
  "#84b6eb",
  "#e6e6e6",
  "#ffffff",
  "#cc317c",
]

getColour = (branch) ->
  n = COLOURS.length
  COLOURS[branch % n]
  
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

CommitsGraph = React.createClass
  displayName: 'CommitsGraph'
  getDefaultProps: ->
    height: 800
    width: 200
    y_step: 20
    x_step: 20
    orientation: "vertical"
    dotRadius: 3
    lineWidth: 2

  getWidth: ->
    return @props.width if @props.width?

    if @props.orientation is "horizontal"
      (@props.data.length + 2) * @props.x_step
    else
      (branchCount(@props.data) + 0.5) * @props.x_step

  getHeight: ->
    return @props.height if @props.height?

    if @props.orientation is "horizontal"
      (branchCount(@props.data) + 0.5) * @props.y_step
    else
      (@props.data.length + 2) * @props.y_step

  renderGraphCanvas: ->
    canvas = @getDOMNode()
    
    # draw
    @ctx = canvas.getContext("2d")
    @ctx.lineWidth = @props.lineWidth

    for commit, index in @props.data
      @renderCommit(index, commit)

  renderCommit: (idx, [sha, dot, routes_data]) ->
    [dot_offset, dot_branch] = dot

    # draw dot
    {x_step, y_step, width} = @props
    radius = @props.dotRadius
    if @props.orientation is "horizontal"
      x_hori = width - (idx + 0.5) * x_step
      y_hori = (dot_offset + 1) * y_step
      @ctx.fillStyle = getColour(dot_branch)
      @ctx.beginPath()
      @ctx.arc(x_hori, y_hori, radius, 0, 2 * Math.PI, true)
    else
      x = width - (dot_offset + 1) * x_step
      y = (idx + 0.5) * y_step
      @ctx.fillStyle = getColour(dot_branch)
      @ctx.beginPath()
      @ctx.arc(x, y, radius, 0, 2 * Math.PI, true)
    @ctx.fill()

    # draw route
    for route, index in routes_data
      @renderRoute(idx, route)

  renderRoute: (commit_idx, [from, to, branch]) ->
    {x_step, y_step, width} = @props
    if @props.orientation is "horizontal"
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
        @ctx.bezierCurveTo(
          from_x_hori - x_step / 3 * 2,
          from_y_hori + y_step / 4,
          to_x_hori + x_step / 3 * 2,
          to_y_hori - y_step / 4,
          to_x_hori,
          to_y_hori
        )
      else 
        if from_y_hori < to_y_hori
          @ctx.bezierCurveTo(
            from_x_hori - x_step / 3 * 2,
            from_y_hori - y_step / 4,
            to_x_hori + x_step / 3 * 2,
            to_y_hori + y_step / 4,
            to_x_hori,
            to_y_hori
          )
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
        @ctx.bezierCurveTo(
          from_x - x_step / 4,
          from_y + y_step / 3 * 2,
          to_x + x_step / 4,
          to_y - y_step / 3 * 2,
          to_x,
          to_y
        )
    @ctx.stroke()

  componentDidMount: ->
    @renderGraphCanvas()
  componentDidUpdate: ->
    @renderGraphCanvas()

  render: ->
    height = @getHeight()
    width = @getWidth()
    <canvas height={height} width={width} style={{height, width}} />

module.exports = CommitsGraph