class Ship
    constructor: (@xpos, @ypos, @gridwidth, @gridheight) ->
        @_history = []

    @dirtobyte: (direction) ->
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

    move: (direction) ->
        byte = @dirtobyte direction
        if byte in [0x1, 0x7, 0x8] and @xpos > 0
            @xpos -= 1
        if byte in [0x3, 0x4, 0x5] and @xpos < @gridwidth
            @xpos += 1
        if byte in [0x5, 0x6, 0x7] and @ypos > 0
            @ypos -= 1
        if byte in [0x1, 0x2, 0x3] and @ypos < @gridheight
            @ypos += 1
        console.log "Ship moved... " + byte
        @_addhistory byte
        return this

    @_addhistory: (byte) ->
        # Keep history to 50 moves. For rationality reasons.
        if @_history.length >= 50
            @_history.shift()
        @_history.push byte

    # Maybe not the best idea. But eh...
    gethistory: () -> @_history

window.Ship = Ship
