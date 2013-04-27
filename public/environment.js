(function() {
  var Environment;

  Environment = (function() {
    var AsteroidWrapper;

    function Environment() {
      this.asteroids = [];
      this.turn = 0;
      this.playerMove = true;
      this.gridWidth = 200;
      this.gridHeight = 200;
    }

    Environment.prototype.addAsteroid = function(xpos, ypos, vx, vy) {
      var ast, remainingTurns, remturnsX, remturnsY, wrapper;
      ast = new Asteroid(xpos, ypos, vx, vy);
      remturnsX = 0;
      remturnsY = 0;
      if (vx === 0) remturnsX = Infinity;
      if (vy === 0) remturnsY = Infinity;
      if (vx < 0) remturnsX = Math.ceil(xpos / -vx);
      if (vx > 0) remturnsX = Math.ceil((this.gridWidth - xpos) / vx);
      if (vy < 0) remturnsY = Math.ceil(ypos / -vy);
      if (vy > 0) remturnsY = Math.ceil((this.gridHeight - ypos) / vy);
      remainingTurns = Math.min(remturnsX, remturnsY);
      wrapper = new AsteroidWrapper(ast, this.turn, this.turn + remainingTurns);
      return this.asteroids.push(wrapper);
    };

    Environment.prototype.bumpMove = function() {
      var a;
      if (!this.playerMove) {
        this.turn += 1;
        this.asteroids = (function() {
          var _i, _len, _ref, _results;
          _ref = this.asteroids;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            a = _ref[_i];
            if (a.lastTurn > this.turn - 20) _results.push(a);
          }
          return _results;
        }).call(this);
      } else {

      }
      return this.playerMove = !this.playerMove;
    };

    AsteroidWrapper = (function() {

      function AsteroidWrapper(asteroid, initialturn, lastTurn) {
        this.asteroid = asteroid;
        this.initialturn = initialturn;
        this.lastTurn = lastTurn;
      }

      return AsteroidWrapper;

    })();

    return Environment;

  })();

  window.Environment = Environment;

}).call(this);
