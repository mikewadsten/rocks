# Generally taken from github/STRd6/PriorityQueue.js
class PriorityQueue
    constructor: ->
        contents = []
        sortfun = (a, b) ->
            # sort as min-heap (sort for lower)
            b.cost - a.cost
        sorted = no

    @pop: ->
        if not @sorted
            @sort()

        el = contents.pop()
        if el
            return el.obj
        return undefined

    @peek: ->
        if not sorted
            @sort()
        el = contents[contents.length - 1]
        if el
            return el.obj
        return undefined

    @size: ->
        contents.length

    @empty: ->
        contents.length is 0

    @put: (cost, obj) ->
        contents.push {obj: obj, cost: cost}
        sorted = no

    @sort: ->
        contents.sort @sortfun
        sorted = yes

window.PriorityQueue = PriorityQueue
