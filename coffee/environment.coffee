class Environment
    # @asteroids holds on to all asteroids, what turn they
    # showed up in, and what turn they "disappear" in. From this,
    # we can extrapolate asteroids positions -- this is the
    # asteroid-state-environment discussed in paper.

    constructor: (@raphael, @overlay) ->
        @gridWidth = 100
        @gridHeight = 60
        @initialize()

    initialize: () ->
        @raphael.clear();
        @overlay.clear();
        @raphael.rect(0, 0, 1000, 600, 10).attr({fill: "#111", stroke: "none"});
        # tells whose move it is
        @playerMove = true
        @asteroids = []
        # Turn is raw turn count (number of player turns, for instance)
        @turn = 0
        theship = new Ship(@gridWidth/2, @gridHeight/2, @gridWidth, @gridHeight)
        @ship = new ShipWrapper(@raphael, theship)
        @landingZone = new LZWrapper(@raphael, @turn, this)
        @lzpoints = 0
        # text-anchor: start --> left-align text to where I set it to
        @algText = @raphael.text(20, 20, "Algorithm:")
        @algText.attr({"font-size": 14, fill: "#aaa", "text-anchor": "start"})
        @lzpointText = @raphael.text(20, 40, "LZ Points: 0")
        @lzpointText.attr({"font-size": 14, fill: "#aaa", "text-anchor": "start"})
        @turnsText = @raphael.text(20, 60, "Turns: 0")
        @turnsText.attr({"font-size": 14, fill: "#aaa", "text-anchor": "start"})
        # Say "Hey I'm here!"
        if @runloopInterval >= 100
            @landingZone.view.notify @turn
        @movementInterval = 100
        algorithmCount = 3
        @algorithm = switch (Math.floor (Math.random()*algorithmCount))
            when 0 then "lazy"
            when 1 then "mdlbfs"
            else "astar"
        if window.location.toString().indexOf("bfs") isnt -1
            @algorithm = "mdlbfs"
        else if window.location.toString().indexOf("astar") isnt -1
            @algorithm = "astar"
        depth = switch @algorithm
            when "astar" then 30
            when "mdlbfs" then 20
            else 6
        @ssp = new SearchSpace(depth, this)

    updateText: () ->
        @lzpointText.attr('text', "LZ Points: " + @lzpoints)
        @turnsText.attr('text', "Turns: " + @turn)
        alg = switch @algorithm
            when "astar" then "A*"
            when "mdlbfs" then "MDLBFS"
            when "lazy" then "Lazy"
            else "Lazy (by default)"
        @algText.attr('text', "Algorithm: " + alg)

    getNewAsteroidPos: () ->
        # Randomly pick which direction the asteroid comes in from.
        # Up, down, left, right, diagonally?
        from = Math.floor Math.random()*8
        shipx = @ship.ship.xpos
        shipy = @ship.ship.ypos
        gridw = @gridWidth
        gridh = @gridHeight
        # The starting positions for these asteroids are close enough to being straight
        # onto the ship that I don't care.
        downleft = ->
            if shipy > (gridw - shipx) then {x: gridw-1, y: shipy-(gridw-shipx), xvel: -1, yvel: 1}
            else if shipy < (gridw-shipx) then {x: (gridw-shipx)+shipy, y: -2, xvel: -1, yvel: 1}
            else {x: gridw-1, y: -2, xvel: -1, yvel: 1}
        upleft = ->
            x2r = gridw - shipx
            y2b = gridh - shipy
            if y2b > x2r then {x: gridw-1, y: y2b-x2r, xvel: -1, yvel: -1}
            else if y2b < x2r then {x: x2r+y2b, y: gridh-1, xvel: -1, yvel: -1}
            else {x: gridw-1, y: gridh-1, xvel: -1, yvel: -1}
        downright = ->
            if shipy > shipx then {x: -2, y: shipy-shipx, xvel: 1, yvel: 1}
            else if shipy < shipx then {x: shipx-shipy, y: -2, xvel: 1, yvel: 1}
            else {x: -2, y: -2, xvel: 1, yvel: 1}
        upright = ->
            if (gridh-shipy) > shipx then {x: -2, y: (gridh-shipy)-shipx, xvel: 1, yvel: -1}
            else if (gridh-shipy) < shipx
            then {x: shipx-(gridh-shipy), y: gridh-1, xvel: 1, yvel: -1}
            else {x: -2, y: -2, xvel: 1, yvel: -1}
        switch from
            #Coming down, left, up, right...
            when 0 then {x: shipx-1, y: -2, xvel: 0, yvel: 1}
            when 2 then {x: gridw-1, y: shipy-1, xvel: -1, yvel: 0}
            when 4 then {x: shipx - 1, y: gridh-1, xvel: 0, yvel: -1}
            when 6 then {x: -2, y: shipy-1, xvel: 1, yvel: 0}
            # Coming downright, downleft, upleft, upright...
            when 1 then downleft()
            when 3 then upleft()
            when 5 then upright()
            else downright()

    makeNewAsteroid: () ->
        if Math.random() >= 0.5
            return
        {x, y, xvel, yvel} = @getNewAsteroidPos()
        @addAsteroid(x, y, xvel, yvel)

    addAsteroid: (xpos, ypos, vx=1, vy=1) ->
        ast = new Asteroid(xpos, ypos, vx, vy)
        remturnsX = 0
        remturnsY = 0
        if vx == 0 then remturnsX = Infinity
        if vy == 0 then remturnsY = Infinity
        if vx < 0
            remturnsX = Math.ceil((xpos+3) / -vx)
        if vx > 0
            remturnsX = Math.ceil((@gridWidth - xpos + 3) / vx)
        if vy < 0
            remturnsY = Math.ceil((ypos+3) / -vy)
        if vy > 0
            remturnsY = Math.ceil((@gridHeight - ypos) / vy)
        remainingTurns = Math.min(remturnsX, remturnsY)

        wrapper = new AsteroidWrapper(@raphael, ast, @turn, @turn + remainingTurns)
        @asteroids.push wrapper
        @ssp.newAsteroid wrapper

    atLandingZone: () ->
        @landingZone isnt null and @ship.ship.at(@landingZone.xpos, @landingZone.ypos)

    regenLZ: () ->
        if @landingZone
            @landingZone.respawn @turn
        else
            @landingZone = new LZWrapper(@raphael, @turn, this)

    startLoop: (INTERVAL=25) ->
        #INTERVAL = 100
        #INTERVAL = 500
        if INTERVAL <= 0
            console.log "Can't start game loop with no or negative interval!"
            return
        else if window.location.hash and not isNaN(parseInt window.location.hash.substring(1))
            interval = parseInt(window.location.hash.substring(1))
            if interval isnt INTERVAL
                INTERVAL = interval
        @runloopInterval = INTERVAL
        #@runloop = setInterval(fun, INTERVAL)
        @movementInterval = INTERVAL
        window.location.hash = "##{INTERVAL}"
        @bumpMove()

    stopLoop: () ->
        @runloopInterval = -1

    moveLoopMaybe: () ->
        if @runloopInterval > 0 # somewhat arbitrary minimum
            looper = _.bind((() -> @bumpMove()), this)
            setTimeout(looper, @runloopInterval)
        else
            console.log "stopping game loop because interval <= 0"

    explodeIfDead: () ->
        [xpos, ypos] = [@ship.ship.xpos, @ship.ship.ypos]
        turn = @turn
        if _.any(@asteroids, (a) -> a.moveToNow(turn).covers(xpos, ypos))
            # An asteroid has struck the ship!
            @ship.explode()
            text = @raphael.text(500, 300, "Aww... you died")
            text.attr({fill: "#fff", "font-size": 30})
            text.animate({y: 300, "fill-opacity": 0}, 1000)
            # TODO: AJAX to server reporting results
            # (to be uncommented when backend for data collection
            # is in place - e.g. MySQL connection and all)
            if window.location.toString().indexOf("nogo") is -1
                ajax = new XMLHttpRequest()
                ajax.open "POST", "/report", true
                ajax.setRequestHeader "Content-Type", "application/json"
                ajax.send @jsonify()
            @initialize()
            if window.location.toString().indexOf("nogo") is -1
                @startLoop()
            return true
        return false

    bumpMove: () ->
        if not @playerMove
            # End this turn, increment counter to next
            @turn += 1
            # Shift search space
            @ssp.bumpTurn()
            # Respawn landing zone if needed
            if @landingZone.expired @turn
                @landingZone.respawn @turn
            if @movementInterval >= 100
                @landingZone.view.notify @turn
            # Remove any asteroids whose last turn was over 20 turns ago
            onScreenRecently = (ast) -> ast.lastTurn > @turn - 20
            onScreenRecently = _.bind(onScreenRecently, this)
            #@asteroids = (a for a in @asteroids when a.lastTurn > @turn - 20)
            @asteroids = _(@asteroids).filter(onScreenRecently)
            # "Hide" any asteroids who shouldn't be on screen
            for ast in @asteroids
                ast.moveOrHide(@turn)
            @makeNewAsteroid()
            if @explodeIfDead()
                return false
        else
            if @atLandingZone()
                @lzpoints += 1
                @landingZone.respawn @turn

            # Use algorithms to implement movement behavior.
            executor = switch @algorithm
                when "lazy" then LazyAvoidance.execute
                when "mdlbfs" then BreadthFirst.execute
                when "astar" then AStar.execute
                else LazyAvoidance.execute

            probable_survival = executor(this)

            if not probable_survival
                @ship.view.view.attr {fill: "#d00" }

        @playerMove = not @playerMove
        @updateText()
        @moveLoopMaybe()
        return true

    class ShipWrapper
        constructor: (raphael, @ship) ->
            @view = new VShip(raphael, @ship.xpos, @ship.ypos)
            @exploder = raphael.circle(@ship.xpos, @ship.ypos, 0).attr({"fill-opacity": 0, r:0})
            @moveplan = []

        move: (direction) ->
            @ship.move direction
            @view.moveTo(@ship.xpos, @ship.ypos, Env.movementInterval)

        explode: () ->
            initattr =
                cx: (@ship.xpos * PX_PER_CELL) + 5
                cy: (@ship.ypos * PX_PER_CELL) + 5
                r: 0
                "fill-opacity": 1
                "stroke-opacity": 0
            animation =
                "40%":
                    fill: "#ff6600"
                    r: 70
                "60%":
                    fill: "#dd0000"
                    r: 100
                "100%":
                    "fill-opacity": 0
                    r: 130

            @exploder.attr initattr
            @exploder.toFront()
            @exploder.animate animation, 1000

    class AsteroidWrapper
        constructor: (raphael, @asteroid, @initialturn, @lastTurn) ->
            @view = new VAsteroid(raphael, @asteroid.xpos, @asteroid.ypos)

        covers: (x, y) ->
            @asteroid.covers x,y

        moveToNow: (turn) ->
            @asteroid.move turn-@initialturn

        moveOrHide: (currturn) ->
            if currturn >= @lastTurn
                @view.view.hide()
            else
                nextpos = @asteroid.move(currturn - @initialturn)
                @view.animateTo(nextpos.xpos, nextpos.ypos, Env.movementInterval)

    class LZWrapper
        constructor: (@raphael, @firstTurn, @env, @gridw=100, @gridh=60) ->
            half = LZ_TURNS_TO_EXPIRE/2
            left = @env.ship.ship.xpos - half
            right = @env.ship.ship.xpos + half
            top = @env.ship.ship.ypos - half
            bottom = @env.ship.ship.ypos + half
            @xpos = _.random(Math.max(0, left), Math.min(@gridw-1, right))
            @ypos = _.random(Math.max(0, top), Math.min(@gridh-1, bottom))
            #@xpos = Math.floor Math.random()*@gridw
            #@ypos = Math.floor Math.random()*@gridh
            @view = new VLZ(raphael, @firstTurn, @xpos, @ypos)
            @lz = new LandingZone(@xpos, @ypos, @firstTurn)

        expired: (turn) ->
            @lz.expired(turn)

        respawn: (turn) ->
            half = LZ_TURNS_TO_EXPIRE/2
            left = @env.ship.ship.xpos - half
            right = @env.ship.ship.xpos + half
            top = @env.ship.ship.ypos - half
            bottom = @env.ship.ship.ypos + half
            @xpos = _.random(Math.max(0, left), Math.min(@gridw-1, right))
            @ypos = _.random(Math.max(0, top), Math.min(@gridh-1, bottom))
            #@xpos = Math.floor Math.random()*@gridw
            #@ypos = Math.floor Math.random()*@gridh
            @firstTurn = turn
            # Move LZ box to new position
            @view.setPos(@xpos, @ypos)
            @view.firstTurn = @firstTurn
            @lz.firstTurn = @firstTurn
            @lz.xpos = @xpos
            @lz.ypos = @ypos
            @lz.expireTurn = @firstTurn + LZ_TURNS_TO_EXPIRE
            return this

    jsonify: () ->
        jsonObj = {}
        jsonObj.ship = [@ship.ship.xpos, @ship.ship.ypos]
        jsonObj.lz = [@landingZone.xpos, @landingZone.ypos, @landingZone.firstTurn]
        jsonObj.turns = @turn
        jsonObj.lzpoints = @lzpoints
        jsonObj.algorithm = @algorithm
        jsonObj.interval = @runloopInterval
        jsonObj.movePlan = @ship.moveplan
        jsonObj.moveHistory = ""
        for m in @ship.ship.gethistory()
            jsonObj.moveHistory += m
        #jsonObj.moveHistory = @ship.ship.gethistory()
        # On second though let's not send the asteroids in.
        #jsonObj.asteroids = []
        #for ast in @asteroids
            ##aster = ast.asteroid
            #aster = ast.moveToNow(@turn)
            #jsonObj.asteroids.push [aster.xpos, aster.ypos, aster.xvel, aster.yvel, ast.initialturn]
        retval = JSON.stringify jsonObj
        #console.log retval
        retval

window.Environment = Environment
