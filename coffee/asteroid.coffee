class Asteroid
    constructor: (@xpos, @ypos, @xvel, @yvel) ->

    covers: (x, y) ->
        # Because Raphael draws boxes from the top left corner,
        # this needs to be written to consider that. Hence, this code.
        #-1 <= xdiff <= 1 and -1 <= ydiff <= 1
        xdiff = x - @xpos
        ydiff = y - @ypos
        0 <= xdiff <= 2 and 0 <= ydiff <= 2

    move: (turns = 1) ->
        new Asteroid(@xpos + (@xvel*turns),
                     @ypos + (@yvel*turns),
                     @xvel, @yvel)

window.Asteroid = Asteroid
