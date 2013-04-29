class Environment
    # @asteroids holds on to all asteroids, what turn they
    # showed up in, and what turn they "disappear" in. From this,
    # we can extrapolate asteroids positions -- this is the
    # asteroid-state-environment discussed in paper.

    constructor: (@raphael) ->
        @asteroids = []
        # Turn is raw turn count (number of player turns, for instance)
        @turn = 0
        # tells whose move it is
        @playerMove = yes
        @gridWidth = 100
        @gridHeight = 60
        theship = new Ship(@gridWidth/2, @gridHeight/2, @gridWidth, @gridHeight)
        @ship = new ShipWrapper(@raphael, theship)
        @landingZone = new LZWrapper(@raphael, @turn)
        @lzpoints = 0
        @lzpointText = @raphael.text(60, 20, "LZ Points: 0")
        @lzpointText.attr({"font-size": 16, fill: "#aaa"})
        @turnsText = @raphael.text(60, 50, "Turns: 0")
        @turnsText.attr({"font-size": 16, fill: "#aaa"})
        # Say "Hey I'm here!"
        @landingZone.view.notify @turn

    updateText: () ->
        @lzpointText.attr('text', "LZ Points: " + @lzpoints)
        @turnsText.attr('text', "Turns: " + @turn)

    makeNewAsteroid: () ->
        # TODO: make asteroids come in from any direction...
        # if fromdir in 0..3, make new asteroid. else, don't
        fromdir = Math.floor Math.random()*8
        switch fromdir
            when 0 then @addAsteroid(@ship.ship.xpos-1, -2, 0, 1)
            when 1 then @addAsteroid(@gridWidth-1, @ship.ship.ypos-1, -1, 0)
            when 2 then @addAsteroid(@ship.ship.xpos-1, @gridHeight-1, 0, -1)
            when 3 then @addAsteroid(-2, @ship.ship.ypos-1, 1, 0)
            else 0  # do nothing...
        #switch fromdir
            #when 0 then console.log "new asteroid up top?"
            #when 1 then console.log "new asteroid on right?"
            #when 2 then console.log "new asteroid on bottom?"
            #when 3 then console.log "new asteroid on left?"
            #else undefined # do nothing...

    addAsteroid: (xpos, ypos, vx=1, vy=1) ->
        ast = new Asteroid(xpos, ypos, vx, vy)
        remturnsX = 0
        remturnsY = 0
        if vx == 0 then remturnsX = Infinity
        if vy == 0 then remturnsY = Infinity
        if vx < 0
            remturnsX = Math.ceil(xpos / -vx)
        if vx > 0
            remturnsX = Math.ceil((@gridWidth - xpos) / vx)
        if vy < 0
            remturnsY = Math.ceil(ypos / -vy)
        if vy > 0
            remturnsY = Math.ceil((@gridHeight - ypos) / vy)
        remainingTurns = Math.min(remturnsX, remturnsY)

        wrapper = new AsteroidWrapper(@raphael, ast, @turn, @turn + remainingTurns)
        @asteroids.push wrapper

    atLandingZone: () ->
        @landingZone isnt null and @ship.ship.at(@landingZone.xpos, @landingZone.ypos)

    regenLZ: () ->
        if @landingZone
            @landingZone.respawn @turn
        else
            @landingZone = new LZWrapper(@raphael, @turn)

    startLoop: (fun) ->
        INTERVAL = 100
        @runloop = setInterval(fun, INTERVAL)

    stopLoop: () ->
        if @runloop then clearInterval(@runloop)

    bumpMove: () ->
        if not @playerMove
            # End this turn, increment counter to next
            @turn += 1
            # Respawn landign zone if needed
            if @landingZone.expired @turn
                @landingZone.respawn @turn
            @landingZone.view.notify @turn
            # Remove any asteroids whose last turn was over 20 turns ago
            @asteroids = (a for a in @asteroids when a.lastTurn > @turn - 20)
            # "Hide" any asteroids who shouldn't be on screen
            for ast in @asteroids
                ast.moveOrHide(@turn)
            @makeNewAsteroid()
        else
            # TODO: implement player turns
            # Probably by passing an algorithm-object?
            # Random walk
            if @atLandingZone()
                @lzpoints += 1
                @landingZone.respawn @turn

            if @isShipSafeLA()
                @ship.view.view.attr('fill', "#fff")
            else
                @ship.view.view.attr({fill: "#d00"})
                #num = Math.floor (Math.random() * 9)
                num = Math.floor (Math.random() * 8)
                dir = switch num
                    #when 0 then "s"
                    when 0 then "ul"
                    when 1 then "up"
                    when 2 then "ur"
                    when 3 then "r"
                    when 4 then "dr"
                    when 5 then "d"
                    when 6 then "dl"
                    else "l"
                @ship.move dir

        @playerMove = not @playerMove
        @updateText()

    isShipSafeLA: () ->
        xpos = @ship.ship.xpos
        ypos = @ship.ship.ypos
        turn = @turn
        return not _.any(@asteroids, (ast) ->
            moveTurns = turn - ast.initialturn
            ast.asteroid.move(moveTurns).willCoverWithin(xpos, ypos, 2))
        #willNotHitShip = (ast) ->
            #moveTurns = @turn - ast.initialturn
            #return not ast.asteroid.move(moveTurns).willCoverWithin(xpos, ypos, 2)
        #return _.all(@asteroids, willNotHitShip)
        #for ast in @asteroids
            #moveturns = @turn - ast.initialturn
            #if ast.asteroid.move(moveturns).willCoverWithin(xpos, ypos, 2)
                #console.log "ship won't be safe within 2 turns"
                #return false
        #return true

    isShipSafe: () ->
        xpos = @ship.ship.xpos
        ypos = @ship.ship.ypos
        for ast in @asteroids
            if ast.covers(xpos, ypos)
                console.log "An asteroid covers the ship?"
                return false
        return true

    class ShipWrapper
        constructor: (raphael, @ship) ->
            @view = new VShip(raphael, @ship.xpos, @ship.ypos)
            @exploder = raphael.circle(@ship.xpos, @ship.ypos, 0).attr({"fill-opacity": 0, r:0})

        move: (direction) ->
            @ship.move direction
            @view.moveTo(@ship.xpos, @ship.ypos, 100)

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

        moveOrHide: (currturn) ->
            if currturn >= @lastTurn
                @view.view.hide()
            else
                nextpos = @asteroid.move(currturn - @initialturn)
                @view.animateTo(nextpos.xpos, nextpos.ypos, 100)

    class LZWrapper
        constructor: (@raphael, @firstTurn, @gridw=100, @gridh=60) ->
            @xpos = Math.floor Math.random()*@gridw
            @ypos = Math.floor Math.random()*@gridh
            @view = new VLZ(raphael, @firstTurn, @xpos, @ypos)
            @lz = new LandingZone(@xpos, @ypos, @firstTurn)

        expired: (turn) ->
            @lz.expired(turn)

        respawn: (turn) ->
            @xpos = Math.floor Math.random()*@gridw
            @ypos = Math.floor Math.random()*@gridh
            @firstTurn = turn
            # Move LZ box to new position
            @view.setPos(@xpos, @ypos)
            @view.firstTurn = @firstTurn
            @lz.firstTurn = @firstTurn
            @lz.xpos = @xpos
            @lz.ypos = @ypos
            @lz.expireTurn = @firstTurn + LZ_TURNS_TO_EXPIRE
            return this

window.Environment = Environment
