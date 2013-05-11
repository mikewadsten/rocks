class Grid
    class Node
        constructor: (@x, @y, @turn) ->
            @opened = false
            @closed = false # closed - search is done with it, or it is un-navigable
            @parent = null  # node we were at before this

    constructor: (@width, @height, @turn) ->
        #console.log "new Grid " + @width + " " + @height + " " + @turn
        @_nodes = @_buildNodes(@width, @height, @turn)

    _buildNodes: (w, h, turn) ->
        nodes = new Array(w)
        for i in [0..w-1]
            nodes[i] = new Array(h)
            for j in [0..h-1]
                nodes[i][j] = new Node(i, j, turn)
        return nodes

    unplanAll: ->
        for i in [0..@width-1]
            for j in [0..@height-1]
                node = @_nodes[i][j]
                node.parent = null
                node.opened = false

    # Whenever a new asteroid appears in the environment, this will
    # be called to ensure the spots it will cover are marked as closed.
    closeFootprint: (asteroid) ->
        # first, check the asteroid exists on this turn
        if not (asteroid.initialturn <= @turn <= asteroid.lastTurn)
            return
        {xpos, ypos} = asteroid.moveToNow @turn
        for i in [Math.max(0, xpos)..Math.min(@width-1, xpos+2)]
            for j in [Math.max(0, ypos)..Math.min(@height-1, ypos+2)]
                if @_nodes[i] isnt undefined
                    node = @_nodes[i][j]
                    if node isnt undefined
                        node.closed = true
                    else
                        continue
                else
                    continue
        return undefined

    isSafe: (x, y) ->
        if x < 0 or x >= @width or y < 0 or y >= @height
            return false # keep ships from wanting to head offscreen, stupid things...
        return not @_nodes[x][y].closed

    isUnplanned: (x, y) ->
        if x < 0 or x >= @width or y < 0 or y >= @height
            return false # keep ships from wanting to head offscreen, stupid things...
        return @_nodes[x][y].parent isnt null

    plan: (x, y, parent) ->
        if x < 0 or x >= @width or y < 0 or y >= @height
            return false # keep ships from wanting to head offscreen, stupid things...
        @_nodes[x][y].parent = parent

    # It's best to not call this without checking the indices are in bounds...
    getNodeAt: (x, y) ->
        @_nodes[x][y]

if (typeof module is 'undefined')
    window.Grid = Grid
else
    module.exports = Grid
