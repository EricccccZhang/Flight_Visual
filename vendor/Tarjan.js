/*
 * MIT License
 * https://gist.github.com/chadhutchins/1440602
 */

/*

    var v0 = new Vertex("0");
    var v1 = new Vertex("1");
    var v2 = new Vertex("2");
    var v3 = new Vertex("3");
    var v4 = new Vertex("4");
    var v5 = new Vertex("5");
    var v6 = new Vertex("6");
    var v7 = new Vertex("7");
    var v8 = new Vertex("8");
    var v9 = new Vertex("9");
    var v10 = new Vertex("10");
    var v11 = new Vertex("11");
    var v12 = new Vertex("12");
 
    v0.connections.push(v1);
    v0.connections.push(v5);
    v2.connections.push(v0);
    v2.connections.push(v3);
    v3.connections.push(v2);
    v3.connections.push(v5);
    v4.connections.push(v2);
    v4.connections.push(v2);
    v5.connections.push(v4);
    v6.connections.push(v0);
    v6.connections.push(v9);
    v7.connections.push(v6);
    v7.connections.push(v8);
    v8.connections.push(v7);
    v8.connections.push(v9);
    v9.connections.push(v10);
    v9.connections.push(v11);
    v10.connections.push(v12);
    v11.connections.push(v4);
    v11.connections.push(v12);
    v12.connections.push(v9);
 
    var vertices = [v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12];
    
    var graph = new Graph(vertices);
    var tarjan = new Tarjan(graph);
    
    var scc = tarjan.run();
    console.log(scc);
 */
function TarjanGraph(vertices){
    this.vertices = vertices || [];
}
 
function TarjanVertex(name){
    this.name = name || null;
    this.connections = [];
    
    // used in tarjan algorithm
    // went ahead and explicity initalized them
    this.index= -1;
    this.lowlink = -1;
}
TarjanVertex.prototype = {
    equals: function(vertex){
        // equality check based on vertex name
        return (vertex.name && this.name==vertex.name);
    }
};
 
function TarjanVertexStack(vertices) {
    this.vertices = vertices || [];
}
TarjanVertexStack.prototype = {
    contains: function(vertex){
        for (var i in this.vertices){
            if (this.vertices[i].equals(vertex)){
                return true;
            }
        }
        return false;
    }
};
 
function Tarjan(graph) {
    this.index = 0;
    this.stack = new TarjanVertexStack();
    this.graph = graph;
    this.scc = [];
}
Tarjan.prototype = {
    run: function(){
        for (var i in this.graph.vertices){
            if (this.graph.vertices[i].index<0){
                this.strongconnect(this.graph.vertices[i]);
            }
        }
        return this.scc;
    },
    strongconnect: function(vertex){
        // Set the depth index for v to the smallest unused index
        vertex.index = this.index;
        vertex.lowlink = this.index;
        this.index = this.index + 1;
        this.stack.vertices.push(vertex);
        
        // Consider successors of v
        // aka... consider each vertex in vertex.connections
        for (var i in vertex.connections){
            var v = vertex;
            var w = vertex.connections[i];
            if (w.index<0){
                // Successor w has not yet been visited; recurse on it
                this.strongconnect(w);
                v.lowlink = Math.min(v.lowlink,w.lowlink);
            } else if (this.stack.contains(w)){
                // Successor w is in stack S and hence in the current SCC
                v.lowlink = Math.min(v.lowlink,w.index);
            }
        }
        
        // If v is a root node, pop the stack and generate an SCC
        if (vertex.lowlink==vertex.index){
            // start a new strongly connected component
            var vertices = [];
            var w = null;
            if (this.stack.vertices.length>0){
                do {
                    w = this.stack.vertices.pop();
                    // add w to current strongly connected component
                    vertices.push(w);
                } while (!vertex.equals(w));
            }
            // output the current strongly connected component
            // ... i'm going to push the results to a member scc array variable
            if (vertices.length>0){
                this.scc.push(vertices);
            }
        }
    }
};
function Floyd(graph) {
	this.graph = graph;
}
Floyd.prototype = {
	run: function() {
		this.size = this.graph.vertices.length;
		this.distance = []
		this.next = [];
		for(var i = 0; i < this.size; i++) {
			var subDist = []
			var subNext = []
			for(var j = 0; j < this.size; j++) {
				subDist.push(Number.MAX_VALUE);
				subNext.push(null);
			}
			this.distance.push(subDist);
			this.next.push(subNext)
		}
		for(var i = 0; i < this.size; i++) {
			var thisVert = this.graph.vertices[i];
			for(var j = 0; j < thisVert.connections.length; j++) {
				var connectedVert = thisVert.connections[j];
				this.distance[i][connectedVert.index] = 1
			}
		}
		for(var k = 0; k < this.size; k++) {
			for(var i = 0; i < this.size; i++) {
				for(var j = 0; j < this.size; j++) {
					if(this.distance[i][k] + this.distance[k][j] < this.distance[i][j]) {
						this.distance[i][j] = this.distance[i][k] + this.distance[k][j];
						this.next[i][j] = k
					}
				}
			}
		}
		var results = []
		for(var i = 0; i < this.size; i++) {
			
			for(var j = 0; j < this.size; j++) {
				if(i == j) {
					continue;
				}
				if(this.distance[i][j] === 2) {
					results.push([i,j,this.path(i,j)])
				}
			}
		}
		return results;
	},
	path: function(i,j) {
		if(this.distance[i][j] === Number.MAX_VALUE) {
			return 'no path';
		}
		var intermediate = this.next[i][j]
		if(intermediate === null) {
			return "";
		} else {
			return intermediate;
			return this.path(i, intermediate) +',' + intermediate + ',' + this.path(intermediate,j)
		}
	}
}
function DFS(graph) {
	this.graph = graph;
}
DFS.prototype = {
	run: function() {
		console.log('run');
		console.log(this)
		_.each(this.graph.vertices, function(vertex) {
			vertex.visited = false;
			vertex.recurStack = false;
		})
		_.each(this.graph.vertices,function(vertex) {
			console.log(this.isCyclicUtil(vertex,0))
		},this)
	},
	isCyclicUtil: function(vertex,depth) {
		console.log(vertex.name + " " + depth)
		console.log(vertex);
		vertex.visited = true;
		vertex.recurStack = true
		if(depth > 3) {
			console.log('depth exceeded');
			return false;
		}
		for(var i = 0; i < vertex.connections.length; i++) {
			var nextVertex = vertex.connections[i];
			if(!nextVertex.visited && this.isCyclicUtil(nextVertex,depth+1)) {
				return true;
			} else if(nextVertex.recurStack) {
				return true;
			}
		}
		vertex.recurStack = false;
		return false;
	}
}