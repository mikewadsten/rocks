PX_PER_CELL = 10

class ViewAsteroid
    CELLS_PER_SIDE = 3
    constructor: (@raphael, x=0, y=0) ->
        dimen = CELLS_PER_SIDE * PX_PER_CELL
        x = x * PX_PER_CELL
        y = y * PX_PER_CELL
        @view = @raphael.rect(x, y, dimen, dimen).attr({fill: "#eee", "fill-opacity": 0.6})

    animateTo: (x, y, time=1000) ->
        @view.stop().animate({x: x*PX_PER_CELL, y: y*PX_PER_CELL}, time)

class ViewShip
    CELLS_PER_SIDE = 1
    constructor: (@raphael, x=null, y=null) ->
        if x is null or y is null
            throw "Cannot create ViewShip without position"
        dimen = CELLS_PER_SIDE * PX_PER_CELL
        x = x * PX_PER_CELL
        y = y * PX_PER_CELL
        @view = @raphael.rect(x, y, dimen, dimen).attr({fill: "#fff"})

    moveTo: (x, y, time=1000) ->
        @view.stop().animate({x: x*PX_PER_CELL, y: y*PX_PER_CELL}, time)

window.VAsteroid = ViewAsteroid
window.VShip = ViewShip
