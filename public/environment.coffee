class Environment
    constructor: () ->
        @asteroids = []
        # Turn is raw turn count (number of player turns, for instance)
        @turn = 0
        # tells whose move it is
        @playerMove = yes
        @gridWidth = 200
        @gridHeight = 200

    addAsteroid: (xpos, ypos, vx, vy) ->
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
        wrapper = new AsteroidWrapper(ast, @turn, @turn + remainingTurns)
        @asteroids.push wrapper

    bumpMove: () ->
        if not @playerMove
            # Remove any asteroids whose last turn was over 20 turns ago
            # TODO: check this works precisely as intended
            @asteroids = (a for a in @asteroids when a.lastTurn > @turn - 20)
            # End this turn, increment counter to next
            @turn += 1
        else
            # TODO: implement player turns
        @playerMove = not @playerMove

    class AsteroidWrapper
        constructor: (@asteroid, @initialturn, @lastTurn) ->

window.Environment = Environment