function Asteroid(initX, initY, xvel, yvel) {
    this.x = initX;
    this.y = initY;
    this.vx = xvel;
    this.vy = yvel;
}

Asteroid.prototype.coversCell = function(x, y) {
    if (x === undefined) {
        console.log("coversCell() called without x or y");
        return false;
    }
    if (y === undefined) {
        console.log("coversCell() called without y");
        return false;
    }
    var x = Math.round(x);
    var y = Math.round(y);
    var xdiff = this.x - x;
    var ydiff = this.y - y;
    var xdiff = Math.round(xdiff);
    var ydiff = Math.round(ydiff);
    return xdiff > -2 && xdiff < 2 && ydiff > -2 && ydiff < 2;
}

Asteroid.prototype.move = function(turns) {
    var turns = turns || 1;

    var newx = this.x + (this.vx * turns),
        newy = this.y + (this.vy * turns);

    return new Asteroid(newx, newy, this.vx, this.vy);
}

module.exports = Asteroid;
