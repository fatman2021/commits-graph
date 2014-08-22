React = require('react');
Graph = require('./src/svg-commits-graph.coffee');

var $ = require('jquery');
function draw() {
  $("[data-graph]").each(function() {
    var props = {
      data: $(this).data("graph"),
      width: $(window).width()/2,
      height: $(window).height(),
    };
    return React.renderComponent(Graph(props), $(this).get(0));
  });
}

$(window).resize(draw);
draw();