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
    @isLandingZone: ({x, y, turn}, env) ->
        x is env.landingZone.xpos and y is env.landingZone.ypos and
                    not env.landingZone.expired(turn)

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
            neighbors = env.ssp.getNeighbors(node, (node.turn - startTurn + 1))
            # If we've gone too deep, or we found the Landing Zone
            if BreadthFirst.isLandingZone(node, env) or node.turn > depthTurn or
                            ((_.isEmpty neighbors) and (_.isEmpty openList))
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
                    # Force noticing the landing zone first.
                    if BreadthFirst.isLandingZone(n, env)
                        openList.unshift n
                    else
                        openList.push n
                    n.opened = true
                    n.parent = node

class AStar
    @heuristic: ({x, y}, {x: endx, y: endy}) ->
        abs = Math.abs
        # Heuristic: Manhattan distance.
        return abs(x-endx) + abs(y - endy)

    @euclid: ({x, y}, {x: endx, y: endy}) ->
        dx = Math.abs(x-endx)
        dy = Math.abs(y-endy)
        return Math.sqrt(dx*dx + dy*dy)

    @wallDistance: ({x, y}, env) ->
        Math.min(x, y, Math.abs(env.gridWidth - x - 1), Math.abs(env.gridHeight - y - 1))

    @execute: (env) ->
        # Use predetermined flight plan if there is one
        sh = env.ship
        sh.view.view.attr {fill: "#fff"}
        if sh.moveplan.length > 0
            console.log "following moveplan..."
            sh.move (sh.moveplan.shift())
            return true

        openList = new PriorityQueue()
        startNode = env.ssp.grids[1].getNodeAt(env.ship.ship.xpos, env.ship.ship.ypos)
        {xpos: lzx, ypos: lzy} = env.landingZone
        lz = {x: lzx, y: lzy}
        if env.landingZone.expired(env.turn + AStar.euclid(startNode, lz) + 2)
            # The landing zone won't be there is roughly the time it will take to
            # go straight there. Fall back to Lazy
            #console.log "LZ too far away, changing to lazy for now"
            return LazyAvoidance.execute env
        if AStar.wallDistance(lz, env) < AStar.euclid(startNode, lz)
            # LZ is too close to the wall to be logically approached.
            #console.log "LZ too close to wall, switching to lazy for now"
            return LazyAvoidance.execute env
        for g in env.ssp.grids
            g.unplanAll()

        startNode.g = 0
        startNode.f = 0

        startTurn = env.turn

        openList.put 0, startNode
        startNode.opened = true

        while not openList.empty()
            node = openList.pop()
            #console.log "AStar queue loop, found ", node
            #node.closed = true

            # See if we've found the Landing Zone, before it expires.
            # We add an extra turn onto the search so we don't stop as soon as we hit the LZ.
            if node.parent?
                if AStar.heuristic(node.parent, lz) is 0
                    if not env.landingZone.expired(node.parent.turn)
                        # We've found the landing zone
                        #moveplan = _.first(SearchSpace.tracePlan(node),
                                            #(AStar.wallDistance(startNode, env)/2))
                        moveplan = SearchSpace.tracePlan(node)
                        console.log "Found the landing zone!"
                        console.log moveplan
                        sh.moveplan = moveplan
                        sh.move (sh.moveplan.shift() or 0)
                        return true

            searchturn = node.turn - env.turn + 1
            neighbors = env.ssp.getNeighbors(node, searchturn)
            #console.log "neighbors", neighbors
            for n in neighbors
                ng = node.g + 1
                # g-cost of nodes will never be found to be lower: the g-cost is its depth
                # inside the search space, and there's no way to get there faster
                # than (depth) turns
                if (not n.opened)
                    n.g = ng
                    # Heuristic cost: Manhattan distance + inverse distance to wall
                    n.h = n.h || (AStar.heuristic(n, lz) + 5*Math.floor(5/AStar.wallDistance(n, env)))
                    n.f = n.g + n.h
                    n.parent = node
                    n.opened = true
                    openList.put n.f, n
            if not openList.sorted
                openList.sort()

        # We didn't find the Landing Zone. Fall back to MDLBFS
        console.log "AStar failed. Falling back to BFS..."
        return BreadthFirst.execute env

window.LazyAvoidance = LazyAvoidance
window.BreadthFirst = BreadthFirst
window.AStar = AStar
