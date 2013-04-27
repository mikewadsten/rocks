class Grid
    constructor: (@width, @height) ->
        @_nodes = @_makenodes()

    @_makenodes: () ->
        nodes = []
        for i in [0..@width]
            nodes[i] = []
            for j in [0..@height]
                nodes[i][j] = new Node(x, y)
        nodes

    getnode: (x, y) ->
        # If (x,y) in grid, return its node
        if x >= 0 and x < @width and y >= 0 and y < @width
            @_nodes[x][y]
        # Else, return fake unoccupied 'node'
        else new Node(x, y)

    occupied: (x, y) ->
        @getnode(x, y).occupied

    unsafe: (x, y) ->
        @occupied(x-1, y+1) or @occupied(x, y+1) or @occupied(x+1, y+1) or
        @occupied(x-1, y)   or @occupied(x, y)   or @occupied(x+1, y)   or
        @occupied(x-1, y-1) or @occupied(x, y-1) or @occupied(x+1, y-1)
