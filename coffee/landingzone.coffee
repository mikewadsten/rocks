class LandingZone
    TURNS_TO_EXPIRE = 50

    constructor: (@xpos, @ypos, @firstTurn) ->
        @expireTurn = @firstTurn + TURNS_TO_EXPIRE

    expired: (turn) ->
        turn >= @expireTurn

window.LandingZone = LandingZone
