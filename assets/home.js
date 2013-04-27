function startThings() {
    Raphael(function () {
        var r = Raphael("holder", 800, 800),
            c = r.circle(200, 200, 20).attr({stroke: "#fff", "stroke-width": 4});

        // Add background
        r.clear();
        r.rect(0,0,800,800,10).attr({fill: "#666", stroke: "none"});
        var c = r.circle(50, 50, 20).attr({stroke: "#fff", "stroke-width": 4});

        function doAnim() {
            c.stop().animate({
                "20%": {cx: 400, cy: 550, easing: "bounce", callback: function() {}},
                "40%": {cx: 600, cy: 300, easing: "bounce", callback: function() {}},
                "60%": {cx: 780, cy: 200, easing: "bounce", callback: function() {}},
                "80%": {cx: 500, cy: 150, easing: "bounce", callback: function() {}},
                "100%": {cx: 650, cy: 350, easing: "bounce", callback: doAnim}
            }, 5000);
        }

        doAnim();
    });
}
