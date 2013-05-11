class SearchSpace
    constructor: (@depth, @env) ->
        @grids = new Array(@depth)
        @width = @env.gridWidth
        @height = @env.gridHeight
        for i in [0..depth-1]
            @grids[i] = new Grid(@width, @height, i)

    # A utility function.
    @tracePlan: (endNode) ->
        plan = []
        node = endNode
        while node.parent isnt null
            p = node.parent
            dx = (node.x - p.x)
            dy = (node.y - p.y)
            node = p
            move = switch dx
                when -1 then switch dy
                    when -1 then 1
                    when 0 then 8
                    else 7
                when 0 then switch dy
                    when -1 then 2
                    when 0 then 0
                    else 6
                else switch dy
                    when -1 then 3
                    when 0 then 4
                    else 5
            plan.unshift move
        #console.log plan
        return plan

    newAsteroid: (asteroid) ->
        for g in @grids
            g.closeFootprint asteroid

    bumpTurn: () ->
        @grids.shift() # drop first grid in array
        newturn = @env.turn + @depth - 1
        newgrid = new Grid(@width, @height, newturn)
        # extend footprints into new grid
        # but pre-filter the asteroid list to only those which will be on screen then
        for a in _.filter(@env.asteroids, (a) -> a.lastTurn >= newturn)
            newgrid.closeFootprint a
        @grids.push newgrid
        @env.overlay.clear()
        if window.location.toString().indexOf("overlay") is -1
            return
        console.log "starting node checking..."
        for col in @grids[0]._nodes
            for node in _.where(col, {closed: true})
            #for node in col
                circle = @env.overlay.circle(node.x * PX_PER_CELL + 5, node.y * PX_PER_CELL + 5, 2)
                circle.attr('stroke', 0)
                circle.attr({fill: 'red', 'fill-opacity': 0.5})
        for col in @grids[1]._nodes
            for node in _.where(col, {closed: true})
                circle = @env.overlay.circle(node.x * PX_PER_CELL + 5, node.y * PX_PER_CELL + 5, 2)
                circle.attr('stroke', 0)
                circle.attr({fill: 'orange', 'fill-opacity': 0.5})
        for col in @grids[2]._nodes
            for node in _.where(col, {closed: true})
                circle = @env.overlay.circle(node.x * PX_PER_CELL + 5, node.y * PX_PER_CELL + 5, 2)
                circle.attr('stroke', 0)
                circle.attr({fill: 'yellow', 'fill-opacity': 0.5})
        return # just show two-turns out
        for col in @grids[3]._nodes
            for node in _.where(col, {closed: true})
                circle = @env.overlay.circle(node.x * PX_PER_CELL + 5, node.y * PX_PER_CELL + 5, 2)
                circle.attr('stroke', 0)
                circle.attr({fill: 'gray', 'fill-opacity': 0.5})

    slice: (start, end) ->
        @grids.slice start, end

    getNeighbors: (node, turnsAhead, shuffle=true) ->
        if turnsAhead >= @depth
            console.log "getNeighbors(n, #{turnsAhead}), depth #{@depth}"
            return [] # can't go deeper than the search space depth
        {x, y} = node
        {width, height} = this
        xs = _.filter([x-1, x, x+1], (i) -> (0 <= i < width))
        ys = _.filter([y-1, y, y+1], (i) -> (0 <= i < height))
        results = []
        for i in xs
            for j in ys
                # Because we don't want to be 'stupid' and be able to occupy the
                # same space as an asteroid just before it moves, we'll exclude
                # neighbors who aren't safe right now. This should keep it out of
                # some stupid traps like two diagonal-moving asteroids next to each
                # other, "sweeping out" a path and plowing the ship along with it.
                if @grids[turnsAhead-1] and @grids[turnsAhead-1].isSafe(i, j) \
                    and @grids[turnsAhead] and @grids[turnsAhead].isSafe(i,j) \
                    and @grids[turnsAhead+1] and @grids[turnsAhead+1].isSafe(i, j)
                        results.push (@grids[turnsAhead].getNodeAt(i, j))
        # shuffle the 'moves' so that we don't always go up-left in the end...
        if shuffle
            return _.shuffle results
        return results

window.SearchSpace = SearchSpace
