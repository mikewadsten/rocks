(function() {
  var Asteroid, Environment, Grid, Node, Ship;

  Asteroid = (function() {
    function Asteroid(xpos, ypos, xvel, yvel) {
      this.xpos = xpos;
      this.ypos = ypos;
      this.xvel = xvel;
      this.yvel = yvel;
    }

    Asteroid.prototype.covers = function(x, y) {
      var xdiff, ydiff;

      xdiff = this.xpos - x;
      ydiff = this.ypos - y;
      return (-1 <= xdiff && xdiff <= 1) && (-1 <= ydiff && ydiff <= 1);
    };

    Asteroid.prototype.move = function(turns) {
      if (turns == null) {
        turns = 1;
      }
      return new Asteroid(this.xpos + (this.xvel * turns), this.ypos + (this.yvel * turns), this.xvel, this.yvel);
    };

    return Asteroid;

  })();

  window.Asteroid = Asteroid;

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
      if (vx === 0) {
        remturnsX = Infinity;
      }
      if (vy === 0) {
        remturnsY = Infinity;
      }
      if (vx < 0) {
        remturnsX = Math.ceil(xpos / -vx);
      }
      if (vx > 0) {
        remturnsX = Math.ceil((this.gridWidth - xpos) / vx);
      }
      if (vy < 0) {
        remturnsY = Math.ceil(ypos / -vy);
      }
      if (vy > 0) {
        remturnsY = Math.ceil((this.gridHeight - ypos) / vy);
      }
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
            if (a.lastTurn > this.turn - 20) {
              _results.push(a);
            }
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

  Grid = (function() {
    function Grid(width, height) {
      this.width = width;
      this.height = height;
      this._nodes = Grid._makenodes(this.width, this.height);
    }

    Grid._makenodes = function(width, height) {
      var nodes, x, y, _i, _j, _ref, _ref1;

      nodes = [];
      for (x = _i = 0, _ref = width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        nodes[x] = [];
        for (y = _j = 0, _ref1 = height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
          nodes[x][y] = new Node(x, y);
        }
      }
      return nodes;
    };

    Grid.prototype.getnode = function(x, y) {
      if (x >= 0 && x < this.width && y >= 0 && y < this.width) {
        return this._nodes[x][y];
      } else {
        return new Node(x, y);
      }
    };

    Grid.prototype.occupied = function(x, y) {
      return getnode(x, y).occupied;
    };

    Grid.prototype.unsafe = function(x, y) {
      return occupied(x - 1, y + 1) || occupied(x, y + 1) || occupied(x + 1, y + 1) || occupied(x - 1, y) || occupied(x, y) || occupied(x + 1, y) || occupied(x - 1, y - 1) || occupied(x, y - 1) || occupied(x + 1, y - 1);
    };

    return Grid;

  })();

  window.Grid = Grid;

  Node = (function() {
    function Node(xpos, ypos, occupied) {
      this.xpos = xpos;
      this.ypos = ypos;
      this.occupied = occupied != null ? occupied : false;
    }

    return Node;

  })();

  window.Node = Node;

  Ship = (function() {
    function Ship(xpos, ypos, gridwidth, gridheight) {
      this.xpos = xpos;
      this.ypos = ypos;
      this.gridwidth = gridwidth;
      this.gridheight = gridheight;
      this._history = [];
    }

    Ship.dirtobyte = function(direction) {
      switch (direction) {
        case "s":
          return 0x0;
        case "ul":
          return 0x1;
        case "up":
          return 0x2;
        case "ur":
          return 0x3;
        case "r":
          return 0x4;
        case "dr":
          return 0x5;
        case "d":
          return 0x6;
        case "dl":
          return 0x7;
        case "l":
          return 0x8;
        default:
          return 0x0;
      }
    };

    Ship.prototype.move = function(direction) {
      var byte;

      byte = this.dirtobyte(direction);
      if ((byte === 0x1 || byte === 0x7 || byte === 0x8) && this.xpos > 0) {
        this.xpos -= 1;
      }
      if ((byte === 0x3 || byte === 0x4 || byte === 0x5) && this.xpos < this.gridwidth) {
        this.xpos += 1;
      }
      if ((byte === 0x5 || byte === 0x6 || byte === 0x7) && this.ypos > 0) {
        this.ypos -= 1;
      }
      if ((byte === 0x1 || byte === 0x2 || byte === 0x3) && this.ypos < this.gridheight) {
        this.ypos += 1;
      }
      console.log("Ship moved... " + byte);
      this._addhistory(byte);
      return this;
    };

    Ship._addhistory = function(byte) {
      if (this._history.length >= 50) {
        this._history.shift();
      }
      return this._history.push(byte);
    };

    Ship.prototype.gethistory = function() {
      return this._history;
    };

    return Ship;

  })();

  window.Ship = Ship;

}).call(this);
