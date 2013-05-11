class LazyAvoidance
    @shipIsSafe: (x, y, turn, asteroids) ->
        _.every(asteroids, (a) ->
            not a.moveToNow(turn).willCoverWithin(x, y, 2))

    @printPossibilities: (lis) ->
        out = ""
        for val in lis
            if val.length is 1
                out += "(#{val[0]})"
            else
                out += "(#{val[0]},#{val[1]})"
        out

    @execute: (env) ->
        sh = env.ship
        # Because of my unfortunate nomenclature, we need to get
        # Env.ship.ship to see the actual ship position, etc.
        ship = sh.ship
        x = ship.xpos
        y = ship.ypos
        asteroids = env.asteroids
        # Is the ship safe?
        if LazyAvoidance.shipIsSafe(x, y, env.turn, asteroids)
            # The ship is safe. Keep calm and carry on.
            sh.view.view.attr {fill: "#fff"}
            sh.moveplan = []
            return true
        # Follow move plan if there is one.
        if sh.moveplan.length > 0
            sh.move (sh.moveplan.shift())
            return true

        sh.view.view.attr {fill: "#ff0"}
        # Plan out moves.
        possibilities = []
        for i in [0..8]
            # Get eventual position after move
            {xpos, ypos} = ship.pretendMove i
            # if xpos,ypos is occupied in the next two turns, skip this move
            if _.any(asteroids, (a) ->
                    a.moveToNow(env.turn).willCoverWithin(xpos, ypos, 1))
                # Don't want to move this way - will run into something.
                #console.log "can't move #{i}"
                continue
            # Just moving the ship one cell will save it for now
            possibilities.push [i]
            # Check one more move into the future.
            for j in [0..8]
                {xpos, ypos} = ship.pretendMove(i, j)
                # Look ahead two turns from the second position...
                if _.any(asteroids, (a) ->
                        a.moveToNow(env.turn + 1).willCoverWithin(xpos, ypos, 2))
                #if _.any(env.ssp.slice(1, 4), (grid) -> not grid.isSafe(xpos, ypos))
                    # This would be an unsafe second move.
                    #console.log "can't move #{i},#{j}"
                    continue
                possibilities.push [i, j]
        # Pick a move plan if one exists
        if _(possibilities).size() is 0
            # There's nowhere for us to go. What a sad day...
            return false
        movetwo = _.filter(possibilities, (p) -> p.length is 2)
        if _(movetwo).size() > 0
            # Pick a random two-move plan to add to moveplan
            plan = movetwo[_.random(movetwo.length - 1)]
            [].push.apply sh.moveplan, plan
        else
            # Pick a random one-move plan to add...
            plan = possibilities[_.random(possibilities.length - 1)]
            [].push.apply sh.moveplan, plan
        # Execute the first move in the new moveplan
        sh.move (sh.moveplan.shift())
        return true

class BreadthFirst
    @getNeighbors: (node, turnsahead, env) ->
        ssp = env.ssp
        if turnsahead >= ssp.depth
            return [] # can't go deeper than we know of
        {x, y} = node
        xs = _.filter([x-1, x, x+1], (i) -> (0 <= i < env.gridWidth))
        ys = _.filter([y-1, y, y+1], (i) -> (0 <= i < env.gridHeight))
        results = []
        # shuffle the 'moves' so that we don't always go up-left in the end...
        for i in _.shuffle xs
            for j in _.shuffle ys
                # Because we don't want to be 'stupid' and be able to occupy the
                # same space as an asteroid just before it moves, we'll exclude
                # neighbors who aren't safe right now. This should keep it out of
                # some stupid traps like two diagonal-moving asteroids next to each
                # other, "sweeping out" a path and plowing the ship along with it.
                if ssp.grids[turnsahead-1] and ssp.grids[turnsahead-1].isSafe(i, j) \
                    and ssp.grids[turnsahead] and ssp.grids[turnsahead].isSafe(i,j) \
                    and ssp.grids[turnsahead+1] and ssp.grids[turnsahead+1].isSafe(i, j)
                        results.push (ssp.grids[turnsahead].getNodeAt(i, j))
        return results

    # More accurately, modified depth-limited breath-first...
    @execute: (env) ->
        # Use predetermined flight plan if there is one
        sh = env.ship
        if sh.moveplan.length > 0
            sh.move (sh.moveplan.shift())
            return true
        {xpos, ypos} = sh.ship
        xdist = env.gridWidth - xpos - 1
        ydist = env.gridHeight - ypos - 1
        # If halfway to edge < 3, set depth to 3 so we get away from edge faster, maybe.
        maxdepth = Math.floor Math.max(3, _.min([xpos/2, ypos/2, xdist/2, ydist/2]))
        # need this to keep track of search depth as we go
        startTurn = env.turn
        depthTurn = env.turn + maxdepth
        openList = []
        # reset plans
        for g in env.ssp.grids
            g.unplanAll()

        #console.log "searching up until turn #{depthTurn} (depth #{maxdepth})"

        startNode = env.ssp.grids[0].getNodeAt(env.ship.ship.xpos, env.ship.ship.ypos)
        openList.push startNode

        while openList.length
            node = openList.shift()
            # TODO: Handle checking for landing zone
            neighbors = BreadthFirst.getNeighbors(node, (node.turn - startTurn + 1), env)
            if node.turn > depthTurn or ((_.isEmpty neighbors) and (_.isEmpty openList))
                # We've reached the end. Just trace back how to get here...
                if node.turn > depthTurn
                    # we don't want this node, we need its parent
                    node = node.parent
                #console.log node
                opacity = 1
                sh.moveplan = SearchSpace.tracePlan(node)
                #console.log "moveplan: #{sh.moveplan}"
                # equivalent of a do-while
                loop
                    c = env.overlay.circle(node.x * PX_PER_CELL  + 5, node.y * PX_PER_CELL + 5, 5)
                    opacity *= 0.8
                    c.attr({fill: 'red', 'fill-opacity': opacity, stroke: 'gray'})
                    break unless (node = node.parent) isnt null
                sh.move (sh.moveplan.shift() or 0)
                return true
            else
                for n in _(neighbors).where({opened: false, closed: false})
                    openList.push n
                    n.opened = true
                    n.parent = node

class AStar
    # TODO: implement the shit out of this
    @execute: (env) ->
        false

window.LazyAvoidance = LazyAvoidance
window.BreadthFirst = BreadthFirst
