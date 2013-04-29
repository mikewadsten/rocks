PX_PER_CELL = 10

class ViewAsteroid
    CELLS_PER_SIDE = 3
    constructor: (@raphael, x=0, y=0) ->
        dimen = CELLS_PER_SIDE * PX_PER_CELL
        x = x * PX_PER_CELL
        y = y * PX_PER_CELL
        cornerRadius = 5
        @view = @raphael.rect(x, y, dimen, dimen, cornerRadius)
        @view.attr({fill: "#aaa", "fill-opacity": 0.5})

    animateTo: (x, y, time=1000) ->
        @view.toFront()
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

class ViewLZ
    CELLS_PER_SIDE = 1

    constructor: (@raphael, @firstTurn, x=null, y=null) ->
        if x is null or y is null
            throw "Cannot create ViewLZ without position"
        dimen = CELLS_PER_SIDE * PX_PER_CELL
        @xpos = x * PX_PER_CELL
        @ypos = y * PX_PER_CELL
        # green
        @view = @raphael.rect(@xpos, @ypos, dimen, dimen).attr({fill: "#009900"})
        @notifyText = @raphael.text(@xpos, @ypos, "")
        inittext =
            fill: "#fff"
            "font-size": 18
            "fill-opacity": 0
        @notifyText.attr(inittext)

    notify: (turn) ->
        text = "WHAAAA"
        if turn is @firstTurn
            text = "Hey, over here!"
        else if @turnsLeft(turn) % 10 is 0
            text = (@turnsLeft turn) + "!"
        else
            return false
        @notifyText.attr({"fill-opacity": 1})
        @notifyText.attr({x: @xpos, y: @ypos, text: text})
        @notifyText.animate({y: @ypos - 50, "fill-opacity": 0}, 500)

    setPos: (x, y) ->
        @xpos = x * PX_PER_CELL
        @ypos = y * PX_PER_CELL
        locattrs =
            x: @xpos
            y: @ypos
        @view.attr locattrs
        @notifyText.attr locattrs

    turnsLeft: (turn) ->
        (@firstTurn + LZ_TURNS_TO_EXPIRE) - turn

    expired: (turn) ->
        turn >= @firstTurn + LZ_TURNS_TO_EXPIRE

window.VAsteroid = ViewAsteroid
window.VShip = ViewShip
window.VLZ = ViewLZ
window.PX_PER_CELL = PX_PER_CELL
