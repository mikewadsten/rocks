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
    class Node
        constructor: (@x, @y, @turn) ->
            @opened = false
            @closed = false

    @getNeighbors: (x, y, atdepth, env) ->
        ssp = env.ssp
        if atdepth > ssp.depth
            return [] # can't go any deeper.
        xs = _.filter([x-1, x, x+1], (i) -> (0 <= i < env.gridWidth))
        ys = _.filter([y-1, y, y+1], (i) -> (0 <= i < env.gridHeight))
        results = []
        for i in xs
            for j in ys
                results.push (ssp.grids[atdepth].getNodeAt(i, j))
        return results

    # More accurately, modified depth-limited breath-first...
    @execute: (env) ->
        openList = BreadthFirst.getNeighbors(env.ship.ship.xpos, env.ship.ship.ypos, 1, env)
        console.log _.where(openList, {closed: true})
        LazyAvoidance.execute env

class AStar
    # TODO: implement the shit out of this
    @execute: (env) ->
        false

window.LazyAvoidance = LazyAvoidance
window.BreadthFirst = BreadthFirst
