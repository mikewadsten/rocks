class Ship
    CELLS = 1
    constructor: (@xpos, @ypos, @gridwidth, @gridheight) ->
        @_history = []

    at: (x, y) ->
        @xpos == x and @ypos == y

    @dirtobyte: (direction) ->
        if typeof direction is "number"
            return direction
        switch direction
            when "s" then 0x0
            when "ul" then 0x1
            when "up" then 0x2
            when "ur" then 0x3
            when "r" then 0x4
            when "dr" then 0x5
            when "d" then 0x6
            when "dl" then 0x7
            when "l" then 0x8
            else 0x0  # probably not gonna happen

    # takes the direction bytes, NOT the direction string
    pretendMove: (bytes...) ->
        xpos = @xpos
        ypos = @ypos
        for byte in bytes
            if byte in [0x1, 0x7, 0x8]
                xpos -= 1
            else if byte in [0x3, 0x4, 0x5]
                xpos += 1
            # Raphael is flipped: add to ypos for "down"
            if byte in [0x5, 0x6, 0x7]
                ypos += 1
            else if byte in [0x1, 0x2, 0x3]
                ypos -= 1
            # Ensure ship is still in screen.
            if xpos < 0
                xpos = 0
            else if xpos > @gridwidth - CELLS
                xpos = @gridwidth - CELLS
            if ypos < 0
                ypos = 0
            else if ypos > @gridheight - CELLS
                ypos = @gridheight - CELLS
        return {xpos, ypos}

    move: (direction) ->
        byte = Ship.dirtobyte direction
        #console.log "Ship moved... " + byte
        if byte in [0x1, 0x7, 0x8]
            @xpos -= 1
        else if byte in [0x3, 0x4, 0x5]
            @xpos += 1
        # Raphael is flipped: add to ypos for "down"
        if byte in [0x5, 0x6, 0x7]
            @ypos += 1
        else if byte in [0x1, 0x2, 0x3]
            @ypos -= 1

        # Ensure ship is still in screen.
        if @xpos < 0
            @xpos = 0
        else if @xpos > @gridwidth - CELLS
            @xpos = @gridwidth - CELLS
        if @ypos < 0
            @ypos = 0
        else if @ypos > @gridheight - CELLS
            @ypos = @gridheight - CELLS

        @_addhistory byte
        return this

    _addhistory: (byte) ->
        # Keep history to 50 moves. For rationality reasons.
        if @_history.length >= 50
            @_history.shift()
        @_history.push byte

    # Maybe not the best idea. But eh...
    gethistory: () -> @_history

window.Ship = Ship
