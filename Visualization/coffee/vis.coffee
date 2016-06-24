#Class for Parallel Coordinates Chart
class ParallelCoords
  constructor: (data) ->
    @data = data
    @parWidth = 1000
    @parHeight = 300
    @nodes = []
    @lines = []
    @columns = 10
    @axis = d3.svg.axis().orient("left")
    @scales = {
      "Calories" : d3.scale.linear().domain([50,160]).range([@parHeight-30,30]),
      "Protein" : d3.scale.linear().domain([0,6]).range([30,@parHeight-30]),
      "Fat" : d3.scale.linear().domain([0,5]).range([30,@parHeight-30]),
      "Sodium" : d3.scale.linear().domain([0,325]).range([30,@parHeight-30]),
      "Fiber" : d3.scale.linear().domain([0,15]).range([30,@parHeight-30]),
      "Carbohydrates" : d3.scale.linear().domain([0,24]).range([30,@parHeight-30]),
      "Sugars" : d3.scale.linear().domain([0,15]).range([30,@parHeight-30]),
      "Potassium" : d3.scale.linear().domain([0,330]).range([30,@parHeight-30]),
      "Vitamins" : d3.scale.linear().domain([0,100]).range([30,@parHeight-30]),
      "Manufacturer" : d3.scale.ordinal().domain(["A", "G", "N", "P", "K", "Q", "R"]).rangePoints([30, @parHeight - 30])
    }
    @color = d3.scale.ordinal()
      .domain(["A", "G", "N", "P", "K", "Q", "R"])
      .range(colorbrewer.Paired[7])
    @force = d3.layout.force()
      .charge(-120)
      .linkDistance(30)
      .friction(0.8)
    @line = d3.svg.line().x((d) -> d.x).y((d) -> d.y)
    max_amount = d3.max(@data, (d) -> parseInt(d.Calories))
    @radius_scale = d3.scale.pow().exponent(4).domain([0, max_amount]).range([10, 85])

    this.create_nodes()
    this.create_vis()

  getScale: (name, d) =>
    scale = @scales[String(name)]
    if(typeof(d) == "undefined") then console.log name
    if(typeof(d) == "string") then scale(d) else scale(Math.abs(d))

  create_nodes: () =>
    @data.forEach (d) =>
        node = {
          id: d.id
          radius: @radius_scale(parseInt(d.Calories))
          value: d.Calories
          name: d.Cereal
          manufacturer: d.Manufacturer
          type: d.Type
          protein: d.Protein
          fat: d.Fat
          sodium: d.Sodium
          fiber: d.Fiber
          carbs: d.Carbohydrates
          sugars: d.Sugars
          shelf: d.Shelf
          potassium: d.Potassium
          vitamins: d.Vitamins
          weight: d.Weight
          cups: d.Cups
          x: Math.random() * 1000
          y: Math.random() * 800
          color: @color(d.Manufacturer)
        }
        @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value

  show_details: (data, i, element) =>

    content = "<span class=\"name\">Cereal:</span><span class=\"value\"> #{data.name}</span><br/>"
    content +="<span class=\"name\">Calories:</span><span class=\"value\"> #{addCommas(data.value)}</span><br/>"
    content +="<span class=\"name\">Manufacturer:</span><span class=\"value\"> #{data.manufacturer}</span><br/>"
    content +="<span class=\"name\">Type:</span><span class=\"value\"> #{data.type}</span><br/>"
    content +="<span class=\"name\">Protein:</span><span class=\"value\"> #{Math.abs(data.protein)}</span><br/>"
    content +="<span class=\"name\">Fat:</span><span class=\"value\"> #{Math.abs(data.fat)}</span><br/>"
    content +="<span class=\"name\">Sodium:</span><span class=\"value\"> #{Math.abs(data.sodium)}</span><br/>"
    content +="<span class=\"name\">Fiber:</span><span class=\"value\"> #{Math.abs(data.fiber)}</span><br/>"
    content +="<span class=\"name\">Carbohydrates:</span><span class=\"value\"> #{Math.abs(data.carbs)}</span><br/>"
    content +="<span class=\"name\">Sugars:</span><span class=\"value\"> #{Math.abs(data.sugars)}</span><br/>"
    content +="<span class=\"name\">Shelf:</span><span class=\"value\"> #{data.shelf}</span><br/>"
    content +="<span class=\"name\">Potassium:</span><span class=\"value\"> #{Math.abs(data.potassium)}</span><br/>"
    content +="<span class=\"name\">Vitamins:</span><span class=\"value\"> #{Math.abs(data.vitamins)}</span><br/>"
    content +="<span class=\"name\">Weight:</span><span class=\"value\"> #{Math.abs(data.weight)}</span><br/>"
    content +="<span class=\"name\">Cups:</span><span class=\"value\"> #{Math.abs(data.cups)}</span>"
    window.tooltip.showTooltip(content,d3.event)

  hide_details: (data, i, element) =>
    window.tooltip.hideTooltip()

  select: (data, i, element) =>
    #Select the bubble chart circle
    d = d3.select(element).data()
    id = d[0].name
    for i in window.circles[0]
      if i.__data__.name == id
        d3.select(i).style("stroke", "black")
        d3.select(i).style("stroke-width", 7)
    d3.select(element).style("stroke-width", 10)
    .style("stroke-opacity", 1)
    this.show_details(data, i, element)

  unselect: (data, i, element) =>
    #Deselect the bubble chart circle
    d = d3.select(element).data()
    id = d[0].name
    for i in window.circles[0]
      if i.__data__.name == id
        d3.select(i).style("stroke", null)
        d3.select(i).style("stroke-width", 2)
    d3.select(element).style("stroke-width", 2)
    .style("stroke-opacity", 0.2)
    this.hide_details(data, i, element)

  create_vis: () =>
    @parallel = d3.select("#chart-left").append("svg")
      .attr("width", @parWidth)
      .attr("height", @parHeight)
      .attr("id", "svg_parallel")

    @force
      .nodes(@nodes)
      .start()

    #Used for mouse callbacks
    that = this
    
    @lines = @parallel.selectAll("path.node")
      .data(@nodes, (d) -> d.name)
      .attr("id", (d) -> '#' + String(d.name))
      .enter().append("path")
      .attr("class", "node")
      .attr("name", (d) -> d.name)
      .style("stroke-width", 2)
      .style("stroke-opacity", 0.2)
      .style("stroke", (d) => d.color)
      .on("mouseover", (d,i) -> that.select(d,i,this))
      .on("mouseout", (d,i) -> that.unselect(d,i,this))

    @g = @parallel.selectAll("g.trait")
      .data(['Manufacturer', 'Calories','Protein', 'Fat', 'Sodium', 'Fiber', 'Carbohydrates', 'Sugars', 'Potassium', 'Vitamins'])
      .enter().append("svg:g")
      .attr("class", "trait")
      .attr("transform", (d,i) => "translate(" + (40+(@parWidth/@columns)*i) + ")")
    @g.append("svg:g")
      .attr("class", "axis")
      .each((d) -> d3.select(this).call(that.axis.scale(that.scales[String(d)])))
      .append("svg:text")
      .attr("class", "title")
      .attr("text-anchor", "middle")
      .attr("y", 12)
      .text(String)

    @force.on("tick", () =>
    @lines.attr("d", (d,i) =>
      @line([{x:40+(@parWidth/@columns)*0, y:that.getScale('Manufacturer',d.manufacturer)},{x:40+(@parWidth/@columns)*1, y:that.getScale('Calories',d.value)},{x:40+(@parWidth/@columns)*2, y:that.getScale('Protein',d.protein)},{x:40+(@parWidth/@columns)*3, y:that.getScale('Fat',d.fat)},{x:40+(@parWidth/@columns)*4, y:that.getScale('Sodium',d.sodium)},{x:40+(@parWidth/@columns)*5, y:that.getScale('Fiber',d.fiber)},{x:40+(@parWidth/@columns)*6, y:that.getScale('Carbohydrates',Math.abs(d.carbs))},{x:40+(@parWidth/@columns)*7, y:that.getScale('Sugars',Math.abs(d.sugars))},{x:40+(@parWidth/@columns)*8, y:that.getScale('Potassium',d.potassium)},{x:40+(@parWidth/@columns)*9, y:that.getScale('Vitamins',d.vitamins)}])))
    window.lines = @lines

# Class for the Bubble Chart
class BubbleChart
  constructor: (data) ->
    @data = data
    @width = 1000
    @height = 600
    @colSpace = 1000/7 # Space between manufacturer clusters
    window.tooltip = CustomTooltip("cereal_tooltip", 240)

    # Locations the nodes will move towards
    # depends on which view is currently active
    @center = {x: @width / 2, y: @height / 2}
    @manufacturer_centers = {
      "A": {x: @width/2 - @colSpace*1.5, y: @height / 2},
      "G": {x: @width/2 - @colSpace*1, y: @height / 2},
      "N": {x: @width/2 - @colSpace*0.5, y: @height / 2},
      "P": {x: @width / 2, y: @height / 2},
      "K": {x: @width / 2 + @colSpace*0.5, y: @height / 2},
      "Q": {x: @width / 2 + @colSpace*1, y: @height / 2},
      "R": {x: @width / 2 + @colSpace*1.5, y: @height / 2}
    }

    # Used when setting up force and moving around nodes
    @layout_gravity = -0.01
    @damper = 0.1

    # These will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @force = null
    @circles = null
    @circleSelected = null

    # Colorbrewer set of 7 colors (not color-blind safe)
    @fill_color = d3.scale.ordinal()
      .domain(["A", "G","N", "P", "K", "Q", "R"])
      .range(colorbrewer.Paired[7]);

    # Use the max total_amount in the data as the max in the scale's domain
    max_amount = d3.max(@data, (d) -> parseInt(d.Calories))
    @radius_scale = d3.scale.pow().exponent(4).domain([0, max_amount]).range([10, 85])
    @fill_color_calories = d3.scale.linear()
      .domain([0, max_amount])
      .range(["hsl(128,99%,100%)", "hsl(228,30%,20%))"])
    @fill_color_calories.interpolate(d3.interpolateHsl)

    max_sugar = d3.max(@data, (d) -> parseInt(d.Sugars))
    @radius_sugar_scale = d3.scale.pow().exponent(2).domain([0, max_sugar]).range([10, 65])
    @fill_color_sugars = d3.scale.linear()
      .domain([0, max_sugar])
      .range(["hsl(120, 100%, 88%)", "hsl(122, 41%, 40%)" ])
      # .range(["hsl(146, 150%, 100%)", "hsl(150, 80%, 20%)"])
    @fill_color_sugars.interpolate(d3.interpolateHsl)

    max_protein = d3.max(@data, (d) -> parseInt(d.Protein))
    @radius_protein_scale = d3.scale.pow().exponent(2).domain([0, max_protein]).range([10, 65])
    @fill_color_protein = d3.scale.linear()
      .domain([0, max_protein])
      .range(["hsl(350, 150%, 100%)", "hsl(358, 78%, 47%)"])
    @fill_color_protein.interpolate(d3.interpolateHsl)
    @previousStrokeColor = null
    
    this.create_nodes()
    this.create_vis()

  # Create node objects from original data that will serve as the data behind each bubble in the chart.
  # Add each node to @nodes for use in the chart.
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d.id
        radius: @radius_scale(parseInt(d.Calories))
        value: d.Calories
        name: d.Cereal
        manufacturer: d.Manufacturer
        type: d.Type
        protein: d.Protein
        fat: d.Fat
        sodium: d.Sodium
        fiber: d.Fiber
        carbs: d.Carbohydrates
        sugars: d.Sugars
        shelf: d.Shelf
        potassium: d.Potassium
        vitamins: d.Vitamins
        weight: d.Weight
        cups: d.Cups
        x: Math.random() * 1000
        y: Math.random() * 800
        color: @fill_color(d.Manufacturer)
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value

  # Create svg at #vis and then
  # create circle representation for each node
  create_vis: () =>
    @vis = d3.select("#vis").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # "That" is defined because we need this scope's "this" in mouse callbacks.
    that = this

    # Radius is set to 0 initially.
    # The transition sets the radius.
    @circles.enter().append("circle")
      .attr("class", "node")
      .attr("r", 0)
      .attr("fill", (d) => d.color)
      .attr("stroke-width", 2)
      .attr("stroke", (d) => null)
      .attr("id", (d) -> "bubble_#{d.id}")
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))

    # Fancy transitions where bubbles appear.
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)
    window.circles = @circles

  #Force-charging our bubble chart...
  # Dividing by 8 scales down the charge to be
  # appropriate for the visualization dimensions.
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 8

  # Starts up the force layout with the default values.
  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  # Sets up force layout to display all nodes in one circle.
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha

  # Sets the display of bubbles to be separated by manufacturer. Does this by calling move_towards_manufactuer
  display_by_manufacturer: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_manufacturer(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

  setColorBySugar: () =>
    (d) => d.color = @fill_color_sugars(d.sugars)

  color_by_sugars: () =>
    @circles.each(this.setColorBySugar)
      .transition()
      .duration(2000)
      .attr("fill", (d) => @fill_color_sugars(d.sugars))
      .attr("stroke-width", 2)
      .attr("stroke", (d) =>
        d3.hsl(@fill_color_sugars(d.sugars)).darker()
        @previousStrokeColor = "hsl")
    window.circles = @circles

  setColorByCalorie: () =>
    (d) => d.color = @fill_color_calories(d.value)

  color_by_calories: () =>
    @circles.each(this.setColorByCalorie)
      .transition()
      .duration(2000)
      .attr("fill", (d) => @fill_color_calories(d.value))
      .attr("stroke-width", 2)
      .attr("stroke", (d) =>
        d3.hsl(@fill_color_calories(d.value)).darker()
        @previousStrokeColor = "hsl")
    window.circles = @circles

  setColorByManufacturer: () =>
    (d) =>
      d.color = @fill_color(d.manufacturer)

  color_by_manufacturer: () =>
    @circles.each(this.setColorByManufacturer)
      .transition()
      .duration(2000)
      .attr("fill", (d) => d.color)
      .attr("stroke-width", 2)
      .attr("stroke", (d) =>
        d3.rgb(d.color).darker()
        @previousStrokeColor = "rgb")
    window.circles = @circles

  setColorByProtein: () =>
    (d) => d.color = @fill_color_protein(d.protein)

  color_by_protein: () =>
    @circles.each(this.setColorByProtein)
      .transition()
      .duration(2000)
      .attr("fill", (d) => @fill_color_protein(d.protein))
      .attr("stroke-width", 2)
      .attr("stroke", (d) =>
        d3.hsl(@fill_color_protein(d.protein)).darker()
        @previousStrokeColor = "hsl")
    window.circles = @circles

  setRadiusBySugar: () =>
    (d) => d.radius = @radius_sugar_scale(Math.abs(d.sugars))

  resize_by_sugar: () =>
    @circles.each(this.setRadiusBySugar())
      .transition()
      .duration(2000)
      .attr("r", (d) -> d.radius)
    window.circles = @circles

  setRadiusByProtein: () =>
    (d) => d.radius = @radius_protein_scale(Math.abs(d.protein))

  resize_by_protein: () =>
    @circles.each(this.setRadiusByProtein())
      .transition()
      .duration(2000)
      .attr("r", (d) -> d.radius)
    window.circles = @circles

  setRadiusByCalories: () =>
    (d) => d.radius = @radius_scale(Math.abs(d.value))

  resize_by_calories: () =>
    @circles.each(this.setRadiusByCalories())
      .transition()
      .duration(2000)
      .attr("r", (d) -> d.radius)
    window.circles = @circles

  # Move all circles to their associated @manufacturer_centers
  move_towards_manufacturer: (alpha) =>
    (d) =>
      target = @manufacturer_centers[d.manufacturer]
      d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
      d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  show_details: (data, i, element) =>
    d3.select(element).attr("stroke", "black")
    d3.select(element).style("stroke-width", 7)

    #Select the parallel coordinate line
    d = d3.select(element).data()
    id = d[0].name
    for i in window.lines[0]
      if i.__data__.name == id
        d3.select(i).style("stroke-width", 10)
        .style("stroke-opacity", 1)

    content = "<span class=\"name\">Cereal:</span><span class=\"value\"> #{data.name}</span><br/>"
    content +="<span class=\"name\">Calories:</span><span class=\"value\"> #{addCommas(data.value)}</span><br/>"
    content +="<span class=\"name\">Manufacturer:</span><span class=\"value\"> #{data.manufacturer}</span><br/>"
    content +="<span class=\"name\">Type:</span><span class=\"value\"> #{data.type}</span><br/>"
    content +="<span class=\"name\">Protein:</span><span class=\"value\"> #{Math.abs(data.protein)}</span><br/>"
    content +="<span class=\"name\">Fat:</span><span class=\"value\"> #{Math.abs(data.fat)}</span><br/>"
    content +="<span class=\"name\">Sodium:</span><span class=\"value\"> #{Math.abs(data.sodium)}</span><br/>"
    content +="<span class=\"name\">Fiber:</span><span class=\"value\"> #{Math.abs(data.fiber)}</span><br/>"
    content +="<span class=\"name\">Carbohydrates:</span><span class=\"value\"> #{Math.abs(data.carbs)}</span><br/>"
    content +="<span class=\"name\">Sugars:</span><span class=\"value\"> #{Math.abs(data.sugars)}</span><br/>"
    content +="<span class=\"name\">Shelf:</span><span class=\"value\"> #{data.shelf}</span><br/>"
    content +="<span class=\"name\">Potassium:</span><span class=\"value\"> #{Math.abs(data.potassium)}</span><br/>"
    content +="<span class=\"name\">Vitamins:</span><span class=\"value\"> #{Math.abs(data.vitamins)}</span><br/>"
    content +="<span class=\"name\">Weight:</span><span class=\"value\"> #{Math.abs(data.weight)}</span><br/>"
    content +="<span class=\"name\">Cups:</span><span class=\"value\"> #{Math.abs(data.cups)}</span>"
    window.tooltip.showTooltip(content,d3.event)

  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => null)
    d3.select(element).attr("stroke-width", (d) => 2)

    #Deselect the parallel coordinate line
    d = d3.select(element).data()
    id = d[0].name
    for i in window.lines[0]
      if i.__data__.name == id
        d3.select(i).style("stroke-width", 2).style("stroke-opacity", 0.2)
    d3.selectAll("path.node").data(d[0]).style("stroke-width", 2)
    window.tooltip.hideTooltip()

  get_selected: () =>
    @circleSelected

#Export our stuff and get the javascript compiling...
root = exports ? this
$ ->
  #Make our charts from data (csv file)
  chart = null
  parallel_chart = null
  render_parallel = (csv) ->
    parallel_chart = new ParallelCoords csv
  render_bubble = (csv) ->
    chart = new BubbleChart csv
    chart.start()
    root.display_all()
  root.display_all = () =>
    chart.display_group_all()
  root.display_manufacturers = () =>
    chart.display_by_manufacturer()

  #Handle the views...
  root.toggle_view = (view_type) =>
    if view_type == 'manufacturer'
      root.display_manufacturers()
    else if view_type == 'resize_by_sugar'
      chart.resize_by_sugar()
    else if view_type == 'resize_by_calories'
      chart.resize_by_calories()
    else if view_type == 'resize_by_protein'
      chart.resize_by_protein()
    else if view_type == 'calories_in_color'
      chart.color_by_calories()
    else if view_type == 'sugars_in_color'
      chart.color_by_sugars()
    else if view_type == 'manufacturer_by_color'
      chart.color_by_manufacturer()
    else if view_type == 'protein_by_color'
      chart.color_by_protein()
    else
      root.display_all()
      root.nodeSelected = chart.get_selected()

  # Render our visualization charts
  d3.csv "data/a1-cereals.csv", render_bubble
  d3.csv "data/a1-cereals.csv", render_parallel

