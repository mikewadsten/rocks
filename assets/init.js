Raphael(function () {
    var raph = Raphael("holder", 1000, 600);
    // Create black "screen" for environment
    var overlay = Raphael("overlay", 1000, 600);

    window.MyRaphael = raph;
    window.Overlay = overlay;
    window.Env = new Environment(raph, overlay);

    //Env.startLoop(function() {Env.bumpMove();});
    //window.start = function(millis) { Env.startLoop(function() { Env.bumpMove(); }, millis)};
    window.start = function(millis) { Env.startLoop(millis); }
    window.stop = function() { Env.stopLoop(); }
    //start(125);
    start(25); // makes animations smoother
});
