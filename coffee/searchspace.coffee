class SearchSpace
    constructor: (@depth, @env) ->
        @grids = new Array(@depth)
        for i in [0..depth-1]
            @grids[i] = new Grid(@env.gridWidth, @env.gridHeight, i)

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
        console.log plan
        return plan

    newAsteroid: (asteroid) ->
        for g in @grids
            g.closeFootprint asteroid

    bumpTurn: () ->
        @grids.shift() # drop first grid in array
        newturn = @env.turn + @depth - 1
        newgrid = new Grid(@env.gridWidth, @env.gridHeight, newturn)
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

window.SearchSpace = SearchSpace
