class Environment
    # @asteroids holds on to all asteroids, what turn they
    # showed up in, and what turn they "disappear" in. From this,
    # we can extrapolate asteroids positions -- this is the
    # asteroid-state-environment discussed in paper.

    constructor: (@raphael) ->
        @gridWidth = 100
        @gridHeight = 60
        @initialize()

    initialize: () ->
        @raphael.clear();
        @raphael.rect(0, 0, 1000, 600, 10).attr({fill: "#111", stroke: "none"});
        # tells whose move it is
        @playerMove = no
        @asteroids = []
        # Turn is raw turn count (number of player turns, for instance)
        @turn = 0
        theship = new Ship(@gridWidth/2, @gridHeight/2, @gridWidth, @gridHeight)
        @ship = new ShipWrapper(@raphael, theship)
        @landingZone = new LZWrapper(@raphael, @turn)
        @lzpoints = 0
        @lzpointText = @raphael.text(60, 20, "LZ Points: 0")
        @lzpointText.attr({"font-size": 16, fill: "#aaa"})
        @turnsText = @raphael.text(60, 50, "Turns: 0")
        @turnsText.attr({"font-size": 16, fill: "#aaa"})
        # Say "Hey I'm here!"
        if @runloopInterval >= 100
            @landingZone.view.notify @turn
        @movementInterval = 100
        @algorithm = "lazy"

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

    startLoop: (INTERVAL=500) ->
        #INTERVAL = 100
        #INTERVAL = 500
        if window.location.hash and not isNaN(parseInt window.location.hash.substring(1))
            INTERVAL = parseInt(window.location.hash.substring(1))
        @runloopInterval = INTERVAL
        #@runloop = setInterval(fun, INTERVAL)
        @movementInterval = INTERVAL
        @bumpMove()

    stopLoop: () ->
        @runloopInterval = -1

    moveLoopMaybe: () ->
        if @runloopInterval > 0 # somewhat arbitrary minimum
            setTimeout((() -> Env.bumpMove()), @runloopInterval)
        else
            console.log "stopping game loop because interval <= 0"

    bumpMove: () ->
        if not @playerMove
            # End this turn, increment counter to next
            @turn += 1
            # Respawn landign zone if needed
            if @landingZone.expired @turn
                @landingZone.respawn @turn
            if @movementInterval >= 100
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
                # if the ship is safe, ignore moveplan
                @ship.moveplan = []
                @playerMove = not @playerMove
                @updateText()
                @moveLoopMaybe()
                return
            else
                @ship.view.view.attr({fill: "#ff0"})

            avoidanceActive = @executeLazyAvoidance()
            if not avoidanceActive
                console.log "Lazy avoidance has failed us!"
                @ship.view.view.attr({fill: "#d00"})

            [xpos, ypos] = [@ship.ship.xpos, @ship.ship.ypos]
            turn = @turn
            if _.any(@asteroids, (a) -> a.moveToNow(turn).covers(xpos, ypos))
                # An asteroid has struck the ship!
                #stopLoop() not needed here - the loop will stop on its own, duh
                #@stopLoop()
                @ship.explode()
                text = @raphael.text(500, 300, "Aww... you died")
                text.attr({fill: "#fff", "font-size": 30})
                text.animate({y: 300, "fill-opacity": 0}, 1000)
                # TODO: AJAX to server reporting results
                Env.jsonify()
                youDied = () ->
                    Env.initialize()
                    Env.startLoop(Env.runloopInterval)
                _.delay(youDied, 1000)
                return

        @playerMove = not @playerMove
        @updateText()
        @moveLoopMaybe()

    isShipSafeLA: () ->
        xpos = @ship.ship.xpos
        ypos = @ship.ship.ypos
        turn = @turn
        return not _.any(@asteroids, (ast) ->
            moveTurns = turn - ast.initialturn
            ast.asteroid.move(moveTurns).willCoverWithin(xpos, ypos, 2))

    isShipSafe: () ->
        xpos = @ship.ship.xpos
        ypos = @ship.ship.ypos
        for ast in @asteroids
            if ast.covers(xpos, ypos)
                console.log "An asteroid covers the ship?"
                return false
        return true

    # return true if we're going to survive (we hope)
    # return false if we're dying (can't survive threats)
    executeLazyAvoidance: () ->
        #console.log "#{@ship.moveplan.length} moves in moveplan"
        if @ship.moveplan.length > 0
            # moveplan is a 'queue' of moves to execute
            move = @ship.moveplan.shift()
            #console.log "planned move: #{move}"
            @ship.move move
            return true
        else if @isShipSafeLA()
            # the ship is safe. carry on.
            return true
        else
            # we need to plan out our moves
            range = [0..8]
            possible_move_plans = []
            turn = @turn  # because of anon function below
            for i in range
                {xpos, ypos} = @ship.ship.pretendMove i
                if _.all(@asteroids, (ast) ->
                        turns = turn - ast.initialturn # at current turn
                        not ast.asteroid.move(turns).willCoverWithin(xpos, ypos, 1))
                    # moving ship just this one will be okay
                    possible_move_plans.push [i]
                else
                    # discount any first-move which will result in a collision
                    continue
                for j in range
                    {xpos, ypos} = @ship.ship.pretendMove(i,j)
                    if _.all(@asteroids, (ast) ->
                            turns = turn - ast.initialturn
                            not ast.asteroid.move(turns+1).willCoverWithin(xpos, ypos, 1))
                        possible_move_plans.push [i,j]
            # Select move plan, etc.
            #console.log possible_move_plans
            plancount = possible_move_plans.length
            if plancount is 0
                # we're screwed. but... how did we get here?
                return false
            twomoves = _.filter(possible_move_plans, (plan) -> plan.length is 2)
            if twomoves.length is 0
                plan = possible_move_plans[_.random(plancount - 1)]
                [].push.apply @ship.moveplan, plan
            else
                plan = twomoves[_.random(twomoves.length - 1)]
                [].push.apply @ship.moveplan, plan
            # We just planned out this move and the next. Execute the first.
            move = @ship.moveplan.shift()
            #console.log "planned move: #{move}"
            @ship.move move
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
        jsonObj.asteroids = []
        for ast in @asteroids
            aster = ast.asteroid
            jsonObj.asteroids.push [aster.xpos, aster.ypos, aster.xvel, aster.yvel, ast.initialturn]
        console.log (JSON.stringify jsonObj)

window.Environment = Environment
