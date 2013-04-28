class Asteroid
    constructor: (@xpos, @ypos, @xvel, @yvel) ->

    covers: (x, y) ->
        willCover(x, y, 0)

    willCover: (x, y, turns) ->
        # Because Raphael draws boxes from the top left corner,
        # this needs to be written to consider that. Hence, this code.
        xdiff = x - (@xpos + (turns * @xvel))
        ydiff = y - (@ypos + (turns * @yvel))
        0 <= xdiff <= 2 and 0 <= ydiff <= 2

    move: (turns = 1) ->
        new Asteroid(@xpos + (@xvel*turns), @ypos + (@yvel*turns),
                     @xvel, @yvel)

window.Asteroid = Asteroid
