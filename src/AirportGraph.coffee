class AirportGraph
	constructor: () ->
	loopMinSize = 2
	loopMaxSize = 4
	init: (planes) ->
		verticies = []
		@planes = planes
		_.each(planes, (landedPlane,planeIndex) ->
			vertex = null
			fromAirport = landedPlane.from
			toAirport = landedPlane.to
			fromVertex = null
			toVertex = null
			for tarjanVertex in verticies
				if tarjanVertex.name is fromAirport
					fromVertex = tarjanVertex
				if tarjanVertex.name is toAirport
					toVertex = tarjanVertex
			if fromVertex is null
				fromVertex = new TarjanVertex(fromAirport)
				fromVertex.screen = landedPlane.fromScreen
				fromVertex.planeIndex = planeIndex
				fromVertex.index = verticies.length;
				verticies.push(fromVertex)
			if toVertex is null
				toVertex = new TarjanVertex(toAirport)
				toVertex.screen =  landedPlane.toScreen
				toVertex.planeIndex = planeIndex
				toVertex.index = verticies.length;
				verticies.push(toVertex)
			toVertex.connections.push(fromVertex)
			fromVertex.connections.push(toVertex)
		,this)
		
		graph = new TarjanGraph(verticies)
		@graph = graph
		console.log graph
		@findLoops()
		uniquePolys = []
		uniquePolyTracker = []
		_.each @polys, (polyPoints, index) ->
			polyID = 0
			_.each polyPoints, (airportCode) ->
				ap = app.airportsObject[airportCode]
				x = ap.pos[0]
				y = ap.pos[1]
				polyID += (x * 13 + y * 23) #crude hash function
			polyID = Math.round(polyID)
			if uniquePolyTracker.indexOf(polyID) is -1
				uniquePolyTracker.push(polyID)
				uniquePolys.push(polyPoints)
		console.log @polys.length + " " + uniquePolys.length
		@polys = uniquePolys 
		
	findLoops: () =>
		console.log('findloops')
		@polys = []
		_.each(@graph.vertices, @findLoop)
		
	findLoop: (airport, index) =>
		
		for vertex in @graph.vertices
			vertex.explored = false
		@target = airport.name
		@list = []
		@dfs(airport,0)
	dfs: (vertex, depth) ->
		@list.push(vertex.name);
		vertex.explored = true
		for neighbor in vertex.connections
			if neighbor.name is @target and (depth >= loopMinSize and depth <= loopMaxSize)
				@polys.push(@list.slice())
			if neighbor.explored is false
				@dfs(neighbor, depth + 1)
		@list.pop()
	
window.AirportGraph = AirportGraph