Raphael(function () {
    var raph = Raphael("holder", 1000, 600);
    // Create black "screen" for environment
    raph.clear();
    raph.rect(0, 0, 1000, 600, 10).attr({fill: "#111", stroke: "none"});

    window.MyRaphael = raph;
    window.Env = new Environment(raph);

    Env.startLoop(function() {Env.bumpMove();});
});
