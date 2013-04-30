Raphael(function () {
    var raph = Raphael("holder", 1000, 600);
    // Create black "screen" for environment

    window.MyRaphael = raph;
    window.Env = new Environment(raph);

    //Env.startLoop(function() {Env.bumpMove();});
    window.start = function(millis) { Env.startLoop(function() { Env.bumpMove(); }, millis)};
    window.stop = function() { Env.stopLoop(); }
    start(250);
});
