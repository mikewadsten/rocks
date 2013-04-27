class Asteroid
    constructor: (@xpos, @ypos, @xvel, @yvel) ->

    covers: (x, y) ->
        xdiff = @xpos - x
        ydiff = @ypos - y
        -1 <= xdiff <= 1 and -1 <= ydiff <= 1

    move: (turns = 1) ->
        new Asteroid(@xpos + (@xvel*turns),
                     @ypos + (@yvel*turns),
                     @xvel, @yvel)

window.Asteroid = Asteroid
