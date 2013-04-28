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
        # TODO: figure out values for these
        @gridWidth = 100
        @gridHeight = 60
        @ship = new ShipWrapper(@raphael, new Ship(50, 30, @gridWidth, @gridHeight))
        #@ship = new Ship(100, 100, @gridWidth, @gridHeight)

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

        #view = new VAsteroid(@raphael, xpos, ypos)
        wrapper = new AsteroidWrapper(@raphael, ast, @turn, @turn + remainingTurns)
        @asteroids.push wrapper

    bumpMove: () ->
        if not @playerMove
            # End this turn, increment counter to next
            @turn += 1
            # Remove any asteroids whose last turn was over 20 turns ago
            @asteroids = (a for a in @asteroids when a.lastTurn > @turn - 20)
            # "Hide" any asteroids who shouldn't be on screen
            for ast in @asteroids
                ast.moveOrHide(@turn)
        else
            # TODO: implement player turns
            # Probably by passing an algorithm-object?
            # Random walk
            # TODO: Can probably do this better, i.e. floor(num * 10)
            num = Math.random()
            if num < 0.111
                @ship.move "s"
            else if num < 0.222
                @ship.move "ul"
            else if num < 0.333
                @ship.move "up"
            else if num < 0.444
                @ship.move "ur"
            else if num < 0.555
                @ship.move "r"
            else if num < 0.666
                @ship.move "dr"
            else if num < 0.777
                @ship.move "d"
            else if num < 0.888
                @ship.move "dl"
            else
                @ship.move "l"

        @playerMove = not @playerMove

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

        animateExplode: () ->
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
            @exploder.animate animation, 2000

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

window.Environment = Environment
